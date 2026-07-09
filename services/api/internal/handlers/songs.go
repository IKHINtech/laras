package handlers

import (
	"fmt"
	"mime/multipart"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

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

type playbackEntry struct {
	Song      models.Song `json:"song"`
	PlayedAt  time.Time   `json:"played_at"`
	PlayCount int64       `json:"play_count"`
}

type playbackAggregateRow struct {
	SongID    uuid.UUID
	PlayedAt  time.Time
	PlayCount int64
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
	h.DB.Where("song_id = ? AND user_id = ?", song.ID, middleware.UserID(c)).Delete(&models.SongPlayEvent{})
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
	h.recordPlayEvent(c, song)
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
			if start < 0 {
				start = 0
			}
			if end >= size || end < 0 {
				end = size - 1
			}
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

func (h SongHandler) RecentPlayed(c *fiber.Ctx) error {
	uid := middleware.UserID(c)
	limit := parseLimit(c.Query("limit"), 20, 100)

	var rows []playbackAggregateRow
	if err := h.DB.Model(&models.SongPlayEvent{}).
		Select("song_id, max(created_at) as played_at, count(*) as play_count").
		Where("user_id = ?", uid).
		Group("song_id").
		Order("played_at desc").
		Limit(limit).
		Scan(&rows).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to load recent played songs"})
	}

	entries, err := h.buildPlaybackEntries(uid, rows)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to load recent played songs"})
	}
	return c.JSON(fiber.Map{"data": entries})
}

func (h SongHandler) MostPlayed(c *fiber.Ctx) error {
	uid := middleware.UserID(c)
	limit := parseLimit(c.Query("limit"), 20, 100)

	var rows []playbackAggregateRow
	if err := h.DB.Model(&models.SongPlayEvent{}).
		Select("song_id, max(created_at) as played_at, coalesce(sum(play_weight), 0) as play_count").
		Where("user_id = ?", uid).
		Group("song_id").
		Order("play_count desc, played_at desc").
		Limit(limit).
		Scan(&rows).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to load most played songs"})
	}

	entries, err := h.buildPlaybackEntries(uid, rows)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to load most played songs"})
	}
	return c.JSON(fiber.Map{"data": entries})
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

func (h SongHandler) buildPlaybackEntries(uid uuid.UUID, rows []playbackAggregateRow) ([]playbackEntry, error) {
	songIDs := make([]uuid.UUID, 0, len(rows))
	for _, row := range rows {
		songIDs = append(songIDs, row.SongID)
	}
	if len(songIDs) == 0 {
		return []playbackEntry{}, nil
	}

	var songs []models.Song
	if err := h.DB.Where("user_id = ? AND id IN ?", uid, songIDs).Find(&songs).Error; err != nil {
		return nil, err
	}

	songByID := make(map[uuid.UUID]models.Song, len(songs))
	for _, song := range songs {
		songByID[song.ID] = song
	}

	entries := make([]playbackEntry, 0, len(rows))
	for _, row := range rows {
		song, ok := songByID[row.SongID]
		if !ok {
			continue
		}
		entries = append(entries, playbackEntry{
			Song:      song,
			PlayedAt:  row.PlayedAt,
			PlayCount: row.PlayCount,
		})
	}
	return entries, nil
}

func (h SongHandler) recordPlayEvent(c *fiber.Ctx, song models.Song) {
	if !shouldTrackPlayback(c.Get("Range")) {
		return
	}

	uid := middleware.UserID(c)
	var last models.SongPlayEvent
	err := h.DB.
		Where("user_id = ? AND song_id = ?", uid, song.ID).
		Order("created_at desc").
		Limit(1).
		First(&last).Error
	if err == nil && time.Since(last.CreatedAt) < 15*time.Second {
		return
	}
	if err != nil && err != gorm.ErrRecordNotFound {
		return
	}

	_ = h.DB.Create(&models.SongPlayEvent{
		UserID:     uid,
		SongID:     song.ID,
		EventType:  "play_start",
		PositionMS: 0,
		PlayWeight: 1,
	}).Error
}

func shouldTrackPlayback(rangeHeader string) bool {
	if rangeHeader == "" {
		return true
	}
	if !strings.HasPrefix(rangeHeader, "bytes=") {
		return false
	}
	parts := strings.SplitN(strings.TrimPrefix(rangeHeader, "bytes="), "-", 2)
	if len(parts) == 0 {
		return false
	}
	if parts[0] == "" {
		return true
	}
	start, err := strconv.ParseInt(parts[0], 10, 64)
	if err != nil {
		return false
	}
	return start == 0
}

func parseLimit(raw string, fallback, max int) int {
	if raw == "" {
		return fallback
	}
	limit, err := strconv.Atoi(raw)
	if err != nil || limit <= 0 {
		return fallback
	}
	if limit > max {
		return max
	}
	return limit
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
