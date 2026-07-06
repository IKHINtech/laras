package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Base struct {
	ID        uuid.UUID      `json:"id" gorm:"type:uuid;primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

func (b *Base) BeforeCreate(tx *gorm.DB) error {
	if b.ID == uuid.Nil {
		b.ID = uuid.New()
	}
	return nil
}

type User struct {
	Base
	Name         string `json:"name" gorm:"not null"`
	Email        string `json:"email" gorm:"uniqueIndex;not null"`
	PasswordHash string `json:"-" gorm:"not null"`
	Role         string `json:"role" gorm:"not null;default:user"`
}

type Song struct {
	Base
	UserID      uuid.UUID `json:"user_id" gorm:"type:uuid;index;not null"`
	Title       string    `json:"title" gorm:"not null"`
	Artist      string    `json:"artist"`
	Album       string    `json:"album"`
	DurationMS  int64     `json:"duration_ms"`
	MimeType    string    `json:"mime_type"`
	FileName    string    `json:"file_name"`
	StoragePath string    `json:"storage_path"`
	SizeBytes   int64     `json:"size_bytes"`
}

type Favorite struct {
	Base
	UserID uuid.UUID `json:"user_id" gorm:"type:uuid;index;not null"`
	SongID uuid.UUID `json:"song_id" gorm:"type:uuid;index;not null"`
	Song   Song      `json:"song"`
}

type Playlist struct {
	Base
	UserID uuid.UUID      `json:"user_id" gorm:"type:uuid;index;not null"`
	Name   string         `json:"name" gorm:"not null"`
	Items  []PlaylistItem `json:"items,omitempty"`
}

type PlaylistItem struct {
	Base
	PlaylistID uuid.UUID `json:"playlist_id" gorm:"type:uuid;index;not null"`
	SongID     uuid.UUID `json:"song_id" gorm:"type:uuid;index;not null"`
	Position   int       `json:"position" gorm:"not null;default:0"`
	Song       Song      `json:"song"`
}
