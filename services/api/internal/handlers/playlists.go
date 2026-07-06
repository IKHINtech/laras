package handlers

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/ikhintech/laras/services/api/internal/middleware"
	"github.com/ikhintech/laras/services/api/internal/models"
	"gorm.io/gorm"
)

type PlaylistHandler struct{ DB *gorm.DB }

type playlistRequest struct{ Name string `json:"name"` }
type playlistItemRequest struct{ SongID string `json:"song_id"` }

func (h PlaylistHandler) List(c *fiber.Ctx) error {
	var playlists []models.Playlist
	if err := h.DB.Where("user_id = ?", middleware.UserID(c)).Order("created_at desc").Find(&playlists).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to list playlists"})
	}
	return c.JSON(fiber.Map{"data": playlists})
}

func (h PlaylistHandler) Create(c *fiber.Ctx) error {
	var req playlistRequest
	if err := c.BodyParser(&req); err != nil || req.Name == "" {
		return c.Status(400).JSON(fiber.Map{"message": "name is required"})
	}
	playlist := models.Playlist{UserID: middleware.UserID(c), Name: req.Name}
	if err := h.DB.Create(&playlist).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to create playlist"})
	}
	return c.Status(201).JSON(playlist)
}

func (h PlaylistHandler) Detail(c *fiber.Ctx) error {
	playlist, err := h.findOwned(c)
	if err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "playlist not found"})
	}
	return c.JSON(playlist)
}

func (h PlaylistHandler) Rename(c *fiber.Ctx) error {
	playlist, err := h.findOwned(c)
	if err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "playlist not found"})
	}
	var req playlistRequest
	if err := c.BodyParser(&req); err != nil || req.Name == "" {
		return c.Status(400).JSON(fiber.Map{"message": "name is required"})
	}
	playlist.Name = req.Name
	h.DB.Save(&playlist)
	return c.JSON(playlist)
}

func (h PlaylistHandler) Delete(c *fiber.Ctx) error {
	playlist, err := h.findOwned(c)
	if err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "playlist not found"})
	}
	h.DB.Where("playlist_id = ?", playlist.ID).Delete(&models.PlaylistItem{})
	h.DB.Delete(&playlist)
	return c.SendStatus(204)
}

func (h PlaylistHandler) AddItem(c *fiber.Ctx) error {
	playlist, err := h.findOwned(c)
	if err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "playlist not found"})
	}
	var req playlistItemRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "song_id is required"})
	}
	songID, err := uuid.Parse(req.SongID)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "invalid song_id"})
	}
	var song models.Song
	if err := h.DB.Where("id = ? AND user_id = ?", songID, middleware.UserID(c)).First(&song).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "song not found"})
	}
	var maxPos int
	h.DB.Model(&models.PlaylistItem{}).Where("playlist_id = ?", playlist.ID).Select("coalesce(max(position),0)").Scan(&maxPos)
	item := models.PlaylistItem{PlaylistID: playlist.ID, SongID: songID, Position: maxPos + 1}
	if err := h.DB.Create(&item).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to add item"})
	}
	return c.Status(201).JSON(item)
}

func (h PlaylistHandler) RemoveItem(c *fiber.Ctx) error {
	playlist, err := h.findOwned(c)
	if err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "playlist not found"})
	}
	itemID, err := uuid.Parse(c.Params("itemId"))
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "invalid item id"})
	}
	if err := h.DB.Where("id = ? AND playlist_id = ?", itemID, playlist.ID).Delete(&models.PlaylistItem{}).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to remove item"})
	}
	return c.SendStatus(204)
}

func (h PlaylistHandler) findOwned(c *fiber.Ctx) (models.Playlist, error) {
	var playlist models.Playlist
	id, err := uuid.Parse(c.Params("id"))
	if err != nil { return playlist, err }
	err = h.DB.Preload("Items", func(db *gorm.DB) *gorm.DB { return db.Order("position asc") }).Preload("Items.Song").Where("id = ? AND user_id = ?", id, middleware.UserID(c)).First(&playlist).Error
	return playlist, err
}
