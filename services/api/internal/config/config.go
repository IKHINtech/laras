package config

import (
	"bufio"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
)

type Config struct {
	AppName     string
	Port        string
	DatabaseURL string
	JWTSecret   string
	StorageDir  string
	PublicURL   string
}

var loadEnvOnce sync.Once

func Load() Config {
	loadEnvOnce.Do(loadDotEnv)

	return Config{
		AppName:     env("APP_NAME", "Laras API"),
		Port:        env("PORT", "8080"),
		DatabaseURL: env("DATABASE_URL", "host=localhost user=postgres password=1 dbname=laras port=5432 sslmode=disable TimeZone=Asia/Jakarta"),
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

func loadDotEnv() {
	for _, candidate := range envCandidates() {
		if err := loadEnvFile(candidate); err == nil {
			return
		}
	}
}

func envCandidates() []string {
	return []string{
		".env",
		"services/api/.env",
		filepath.Join("..", ".env"),
		filepath.Join("..", "..", ".env"),
		filepath.Join("..", "..", "..", ".env"),
		filepath.Join("..", "..", "..", "services", "api", ".env"),
	}
}

func loadEnvFile(path string) error {
	file, err := os.Open(path)
	if err != nil {
		return err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		line = strings.TrimPrefix(line, "export ")
		key, value, ok := strings.Cut(line, "=")
		if !ok {
			continue
		}

		key = strings.TrimSpace(key)
		value = strings.TrimSpace(value)
		if key == "" {
			continue
		}

		if len(value) >= 2 {
			if unquoted, err := strconv.Unquote(value); err == nil {
				value = unquoted
			}
		}

		if _, exists := os.LookupEnv(key); exists {
			continue
		}
		_ = os.Setenv(key, value)
	}

	return scanner.Err()
}
