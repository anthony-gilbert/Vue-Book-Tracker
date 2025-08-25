package handlers

import (
	"book-tracker-backend/internal/database"
	"book-tracker-backend/internal/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type BookHandler struct {
	db *database.Database
}

func NewBookHandler(db *database.Database) *BookHandler {
	return &BookHandler{db: db}
}

func (h *BookHandler) CreateBook(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	var req models.BookRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Validate status
	if req.Status != "to-read" && req.Status != "reading" && req.Status != "read" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "status must be 'to-read', 'reading', or 'read'"})
		return
	}

	book := &models.Book{
		Title:  req.Title,
		Author: req.Author,
		Status: req.Status,
		UserID: userID.(uint),
	}

	if err := h.db.CreateBook(book); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create book"})
		return
	}

	c.JSON(http.StatusCreated, book)
}

func (h *BookHandler) GetBooks(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	status := c.Query("status")
	
	books, err := h.db.GetBooksByUserID(userID.(uint), status)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch books"})
		return
	}

	response := models.BookResponse{
		Books: books,
		Count: len(books),
	}

	c.JSON(http.StatusOK, response)
}

func (h *BookHandler) UpdateBookStatus(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	bookIDStr := c.Param("id")
	bookID, err := strconv.ParseUint(bookIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid book ID"})
		return
	}

	var req struct {
		Status string `json:"status" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Validate status
	if req.Status != "to-read" && req.Status != "reading" && req.Status != "read" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "status must be 'to-read', 'reading', or 'read'"})
		return
	}

	book, err := h.db.UpdateBookStatus(uint(bookID), userID.(uint), req.Status)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Book not found"})
		return
	}

	c.JSON(http.StatusOK, book)
}

func (h *BookHandler) DeleteBook(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	bookIDStr := c.Param("id")
	bookID, err := strconv.ParseUint(bookIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid book ID"})
		return
	}

	err = h.db.DeleteBook(uint(bookID), userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete book"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Book deleted successfully"})
}

func (h *BookHandler) HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status": "healthy",
		"service": "book-tracker-backend",
	})
}