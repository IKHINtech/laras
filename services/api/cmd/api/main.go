package main

import (
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/ikhintech/laras/services/api/internal/config"
	"github.com/ikhintech/laras/services/api/internal/database"
	"github.com/ikhintech/laras/services/api/internal/handlers"
	"github.com/ikhintech/laras/services/api/internal/middleware"
)

func main() {
	cfg := config.Load()
	if err := os.MkdirAll(cfg.StorageDir, 0755); err != nil {
		log.Fatal(err)
	}
	db, err := database.Connect(cfg.DatabaseURL)
	if err != nil {
		log.Fatal(err)
	}
	if err := database.AutoMigrate(db); err != nil {
		log.Fatal(err)
	}

	app := fiber.New(fiber.Config{AppName: cfg.AppName, BodyLimit: 100 * 1024 * 1024})
	app.Use(logger.New())
	app.Use(cors.New(cors.Config{AllowOrigins: "*", AllowHeaders: "Origin, Content-Type, Accept, Authorization"}))

	authHandler := handlers.AuthHandler{DB: db, JWTSecret: cfg.JWTSecret}
	songHandler := handlers.SongHandler{DB: db, StorageDir: cfg.StorageDir, PublicURL: cfg.PublicURL}
	playlistHandler := handlers.PlaylistHandler{DB: db}
	favoriteHandler := handlers.FavoriteHandler{DB: db}

	app.Get("/health", func(c *fiber.Ctx) error { return c.JSON(fiber.Map{"status": "ok", "app": cfg.AppName}) })

	api := app.Group("/api/v1")
	api.Post("/auth/register", authHandler.Register)
	api.Post("/auth/login", authHandler.Login)

	private := api.Group("", middleware.Auth(cfg.JWTSecret))
	private.Get("/me", authHandler.Me)
	private.Get("/stats", songHandler.Stats)
	private.Get("/songs/recent-played", songHandler.RecentPlayed)
	private.Get("/songs/most-played", songHandler.MostPlayed)
	private.Get("/songs", songHandler.List)
	private.Post("/songs/upload", songHandler.Upload)
	private.Get("/songs/:id", songHandler.Get)
	private.Delete("/songs/:id", songHandler.Delete)
	private.Get("/songs/:id/stream", songHandler.Stream)

	private.Get("/favorites", favoriteHandler.List)
	private.Post("/favorites/:songId/toggle", favoriteHandler.Toggle)

	private.Get("/playlists", playlistHandler.List)
	private.Post("/playlists", playlistHandler.Create)
	private.Get("/playlists/:id", playlistHandler.Detail)
	private.Put("/playlists/:id", playlistHandler.Rename)
	private.Delete("/playlists/:id", playlistHandler.Delete)
	private.Post("/playlists/:id/items", playlistHandler.AddItem)
	private.Delete("/playlists/:id/items/:itemId", playlistHandler.RemoveItem)

	log.Fatal(app.Listen(":" + cfg.Port))
}
