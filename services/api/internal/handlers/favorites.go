package handlers

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/ikhintech/laras/services/api/internal/middleware"
	"github.com/ikhintech/laras/services/api/internal/models"
	"gorm.io/gorm"
)

type FavoriteHandler struct{ DB *gorm.DB }

func (h FavoriteHandler) List(c *fiber.Ctx) error {
	var favs []models.Favorite
	if err := h.DB.Preload("Song").Where("user_id = ?", middleware.UserID(c)).Order("created_at desc").Find(&favs).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to list favorites"})
	}
	return c.JSON(fiber.Map{"data": favs})
}

func (h FavoriteHandler) Toggle(c *fiber.Ctx) error {
	uid := middleware.UserID(c)
	songID, err := uuid.Parse(c.Params("songId"))
	if err != nil { return c.Status(400).JSON(fiber.Map{"message": "invalid song id"}) }
	var song models.Song
	if err := h.DB.Where("id = ? AND user_id = ?", songID, uid).First(&song).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "song not found"})
	}
	var fav models.Favorite
	err = h.DB.Where("user_id = ? AND song_id = ?", uid, songID).First(&fav).Error
	if err == nil {
		h.DB.Delete(&fav)
		return c.JSON(fiber.Map{"favorite": false})
	}
	fav = models.Favorite{UserID: uid, SongID: songID}
	if err := h.DB.Create(&fav).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to favorite song"})
	}
	return c.JSON(fiber.Map{"favorite": true})
}
