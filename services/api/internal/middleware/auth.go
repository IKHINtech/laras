package middleware

import (
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/ikhintech/laras/services/api/internal/utils"
)

func Auth(secret string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		authHeader := c.Get("Authorization")
		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"message": "missing bearer token"})
		}
		claims, err := utils.ParseToken(secret, strings.TrimPrefix(authHeader, "Bearer "))
		if err != nil {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"message": "invalid token"})
		}
		uid, err := uuid.Parse(claims.UserID)
		if err != nil {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"message": "invalid user id"})
		}
		c.Locals("user_id", uid)
		c.Locals("email", claims.Email)
		c.Locals("role", claims.Role)
		return c.Next()
	}
}

func UserID(c *fiber.Ctx) uuid.UUID {
	uid, _ := c.Locals("user_id").(uuid.UUID)
	return uid
}
