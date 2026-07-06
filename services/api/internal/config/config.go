package config

import "os"

type Config struct {
	AppName     string
	Port        string
	DatabaseURL string
	JWTSecret   string
	StorageDir  string
	PublicURL   string
}

func Load() Config {
	return Config{
		AppName:     env("APP_NAME", "Laras API"),
		Port:        env("PORT", "8080"),
		DatabaseURL: env("DATABASE_URL", "host=localhost user=laras password=laras dbname=laras port=5432 sslmode=disable TimeZone=Asia/Jakarta"),
		JWTSecret:   env("JWT_SECRET", "change-me-in-production"),
		StorageDir:  env("STORAGE_DIR", "./storage/music"),
		PublicURL:   env("PUBLIC_URL", "http://localhost:8080"),
	}
}

func env(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
