package handlers

import (
	"fmt"
	"mime/multipart"
	"os"
	"path/filepath"
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/ikhintech/laras/services/api/internal/middleware"
	"github.com/ikhintech/laras/services/api/internal/models"
	"gorm.io/gorm"
)

type SongHandler struct {
	DB         *gorm.DB
	StorageDir string
	PublicURL  string
}

func (h SongHandler) List(c *fiber.Ctx) error {
	uid := middleware.UserID(c)
	q := strings.TrimSpace(c.Query("q"))
	var songs []models.Song
	db := h.DB.Where("user_id = ?", uid).Order("created_at desc")
	if q != "" {
		like := "%" + strings.ToLower(q) + "%"
		db = db.Where("lower(title) LIKE ? OR lower(artist) LIKE ? OR lower(album) LIKE ?", like, like, like)
	}
	if err := db.Find(&songs).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to list songs"})
	}
	return c.JSON(fiber.Map{"data": songs})
}

func (h SongHandler) Upload(c *fiber.Ctx) error {
	uid := middleware.UserID(c)
	file, err := c.FormFile("file")
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "file is required"})
	}
	if !allowedAudio(file) {
		return c.Status(422).JSON(fiber.Map{"message": "unsupported audio type"})
	}
	userDir := filepath.Join(h.StorageDir, uid.String())
	if err := os.MkdirAll(userDir, 0755); err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to prepare storage"})
	}
	id := uuid.New()
	ext := strings.ToLower(filepath.Ext(file.Filename))
	storedName := id.String() + ext
	path := filepath.Join(userDir, storedName)
	if err := c.SaveFile(file, path); err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to save file"})
	}
	title := c.FormValue("title")
	if title == "" {
		title = strings.TrimSuffix(file.Filename, filepath.Ext(file.Filename))
	}
	song := models.Song{
		UserID:      uid,
		Title:       title,
		Artist:      c.FormValue("artist"),
		Album:       c.FormValue("album"),
		MimeType:    detectMime(file),
		FileName:    file.Filename,
		StoragePath: path,
		SizeBytes:   file.Size,
	}
	song.ID = id
	if err := h.DB.Create(&song).Error; err != nil {
		_ = os.Remove(path)
		return c.Status(500).JSON(fiber.Map{"message": "failed to save song metadata"})
	}
	return c.Status(201).JSON(song)
}

func (h SongHandler) Get(c *fiber.Ctx) error {
	song, err := h.findOwnedSong(c)
	if err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "song not found"})
	}
	return c.JSON(song)
}

func (h SongHandler) Delete(c *fiber.Ctx) error {
	song, err := h.findOwnedSong(c)
	if err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "song not found"})
	}
	_ = os.Remove(song.StoragePath)
	if err := h.DB.Delete(&song).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to delete song"})
	}
	return c.SendStatus(204)
}

func (h SongHandler) Stream(c *fiber.Ctx) error {
	song, err := h.findOwnedSong(c)
	if err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "song not found"})
	}
	file, err := os.Open(song.StoragePath)
	if err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "audio file missing"})
	}
	defer file.Close()

	stat, err := file.Stat()
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to stat file"})
	}

	size := stat.Size()
	start := int64(0)
	end := size - 1
	status := fiber.StatusOK

	if rangeHeader := c.Get("Range"); strings.HasPrefix(rangeHeader, "bytes=") {
		parts := strings.Split(strings.TrimPrefix(rangeHeader, "bytes="), "-")
		if len(parts) == 2 {
			if parts[0] != "" {
				_, _ = fmt.Sscanf(parts[0], "%d", &start)
			}
			if parts[1] != "" {
				_, _ = fmt.Sscanf(parts[1], "%d", &end)
			}
			if start < 0 { start = 0 }
			if end >= size || end < 0 { end = size - 1 }
			if start > end {
				c.Set("Content-Range", fmt.Sprintf("bytes */%d", size))
				return c.SendStatus(fiber.StatusRequestedRangeNotSatisfiable)
			}
			status = fiber.StatusPartialContent
			c.Set("Content-Range", fmt.Sprintf("bytes %d-%d/%d", start, end, size))
		}
	}

	length := end - start + 1
	if _, err := file.Seek(start, 0); err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to seek file"})
	}
	c.Status(status)
	c.Set("Accept-Ranges", "bytes")
	c.Set("Content-Type", song.MimeType)
	c.Set("Content-Length", fmt.Sprintf("%d", length))
	return c.SendStream(file, int(length))
}

func (h SongHandler) Stats(c *fiber.Ctx) error {
	uid := middleware.UserID(c)
	var totalSongs int64
	var totalBytes int64
	h.DB.Model(&models.Song{}).Where("user_id = ?", uid).Count(&totalSongs)
	h.DB.Model(&models.Song{}).Select("coalesce(sum(size_bytes),0)").Where("user_id = ?", uid).Scan(&totalBytes)
	return c.JSON(fiber.Map{"total_songs": totalSongs, "total_storage_bytes": totalBytes})
}

func (h SongHandler) findOwnedSong(c *fiber.Ctx) (models.Song, error) {
	var song models.Song
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return song, err
	}
	err = h.DB.Where("id = ? AND user_id = ?", id, middleware.UserID(c)).First(&song).Error
	return song, err
}

func allowedAudio(file *multipart.FileHeader) bool {
	ext := strings.ToLower(filepath.Ext(file.Filename))
	switch ext {
	case ".mp3", ".m4a", ".flac", ".wav", ".ogg", ".aac":
		return true
	default:
		return false
	}
}

func detectMime(file *multipart.FileHeader) string {
	ext := strings.ToLower(filepath.Ext(file.Filename))
	switch ext {
	case ".mp3":
		return "audio/mpeg"
	case ".m4a":
		return "audio/mp4"
	case ".flac":
		return "audio/flac"
	case ".wav":
		return "audio/wav"
	case ".ogg":
		return "audio/ogg"
	case ".aac":
		return "audio/aac"
	default:
		return "application/octet-stream"
	}
}
