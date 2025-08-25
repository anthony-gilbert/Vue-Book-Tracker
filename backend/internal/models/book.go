package models

import (
	"time"

	"gorm.io/gorm"
)

type Book struct {
	ID           uint           `json:"id" gorm:"primaryKey"`
	Title        string         `json:"title" gorm:"not null"`
	Author       string         `json:"author"`
	Status       string         `json:"status" gorm:"not null"` // "to-read", "reading", "read"
	UserID       uint           `json:"user_id" gorm:"not null"`
	DateAdded    time.Time      `json:"date_added"`
	DateStarted  *time.Time     `json:"date_started,omitempty"`
	DateFinished *time.Time     `json:"date_finished,omitempty"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `json:"-" gorm:"index"`
}

type BookRequest struct {
	Title  string `json:"title" binding:"required"`
	Author string `json:"author"`
	Status string `json:"status" binding:"required"`
}

type BookResponse struct {
	Books []Book `json:"books"`
	Count int    `json:"count"`
}