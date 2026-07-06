package handlers

import (
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/ikhintech/laras/services/api/internal/middleware"
	"github.com/ikhintech/laras/services/api/internal/models"
	"github.com/ikhintech/laras/services/api/internal/utils"
	"gorm.io/gorm"
)

type AuthHandler struct {
	DB        *gorm.DB
	JWTSecret string
}

type registerRequest struct {
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type loginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func (h AuthHandler) Register(c *fiber.Ctx) error {
	var req registerRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "invalid request"})
	}
	req.Email = strings.ToLower(strings.TrimSpace(req.Email))
	if req.Name == "" || req.Email == "" || len(req.Password) < 6 {
		return c.Status(422).JSON(fiber.Map{"message": "name, valid email, and password min 6 chars are required"})
	}
	hash, err := utils.HashPassword(req.Password)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "failed to hash password"})
	}
	user := models.User{Name: req.Name, Email: req.Email, PasswordHash: hash, Role: "user"}
	if err := h.DB.Create(&user).Error; err != nil {
		return c.Status(409).JSON(fiber.Map{"message": "email already registered"})
	}
	token, _ := utils.CreateToken(h.JWTSecret, user.ID, user.Email, user.Role)
	return c.Status(201).JSON(fiber.Map{"token": token, "user": user})
}

func (h AuthHandler) Login(c *fiber.Ctx) error {
	var req loginRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "invalid request"})
	}
	var user models.User
	if err := h.DB.Where("email = ?", strings.ToLower(strings.TrimSpace(req.Email))).First(&user).Error; err != nil {
		return c.Status(401).JSON(fiber.Map{"message": "invalid credentials"})
	}
	if !utils.CheckPassword(user.PasswordHash, req.Password) {
		return c.Status(401).JSON(fiber.Map{"message": "invalid credentials"})
	}
	token, _ := utils.CreateToken(h.JWTSecret, user.ID, user.Email, user.Role)
	return c.JSON(fiber.Map{"token": token, "user": user})
}

func (h AuthHandler) Me(c *fiber.Ctx) error {
	var user models.User
	if err := h.DB.First(&user, "id = ?", middleware.UserID(c)).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "user not found"})
	}
	return c.JSON(user)
}
