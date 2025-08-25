package database

import (
	"book-tracker-backend/internal/models"
	"fmt"
	"time"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

type Database struct {
	DB *gorm.DB
}

func NewDatabase(dbPath string) (*Database, error) {
	db, err := gorm.Open(sqlite.Open(dbPath), &gorm.Config{})
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	// Auto-migrate the schema
	err = db.AutoMigrate(&models.User{}, &models.Book{})
	if err != nil {
		return nil, fmt.Errorf("failed to migrate database: %w", err)
	}

	return &Database{DB: db}, nil
}

// User methods
func (d *Database) CreateUser(user *models.User) error {
	return d.DB.Create(user).Error
}

func (d *Database) GetUserByUsername(username string) (*models.User, error) {
	var user models.User
	err := d.DB.Where("username = ?", username).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (d *Database) GetUserByID(id uint) (*models.User, error) {
	var user models.User
	err := d.DB.First(&user, id).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// Book methods
func (d *Database) CreateBook(book *models.Book) error {
	book.DateAdded = time.Now()
	
	if book.Status == "reading" {
		now := time.Now()
		book.DateStarted = &now
	} else if book.Status == "read" {
		now := time.Now()
		book.DateStarted = &now
		book.DateFinished = &now
	}
	
	return d.DB.Create(book).Error
}

func (d *Database) GetBooksByUserID(userID uint, status string) ([]models.Book, error) {
	var books []models.Book
	query := d.DB.Where("user_id = ?", userID)
	
	if status != "" {
		query = query.Where("status = ?", status)
	}
	
	err := query.Order("created_at DESC").Find(&books).Error
	return books, err
}

func (d *Database) UpdateBookStatus(bookID, userID uint, status string) (*models.Book, error) {
	var book models.Book
	
	// First, find the book and ensure it belongs to the user
	err := d.DB.Where("id = ? AND user_id = ?", bookID, userID).First(&book).Error
	if err != nil {
		return nil, err
	}
	
	// Update status and timestamps
	book.Status = status
	now := time.Now()
	
	if status == "reading" && book.DateStarted == nil {
		book.DateStarted = &now
	} else if status == "read" && book.DateFinished == nil {
		if book.DateStarted == nil {
			book.DateStarted = &now
		}
		book.DateFinished = &now
	}
	
	err = d.DB.Save(&book).Error
	if err != nil {
		return nil, err
	}
	
	return &book, nil
}

func (d *Database) DeleteBook(bookID, userID uint) error {
	return d.DB.Where("id = ? AND user_id = ?", bookID, userID).Delete(&models.Book{}).Error
}

func (d *Database) GetBookByID(bookID, userID uint) (*models.Book, error) {
	var book models.Book
	err := d.DB.Where("id = ? AND user_id = ?", bookID, userID).First(&book).Error
	if err != nil {
		return nil, err
	}
	return &book, nil
}