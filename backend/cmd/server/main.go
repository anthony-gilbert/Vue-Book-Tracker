package main

import (
	"book-tracker-backend/internal/database"
	"book-tracker-backend/internal/handlers"
	"log"
	"os"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	// Initialize database
	dbPath := os.Getenv("DB_PATH")
	if dbPath == "" {
		dbPath = "./books.db"
	}
	
	log.Printf("Initializing database at: %s", dbPath)
	db, err := database.NewDatabase(dbPath)
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}
	log.Println("Database initialized successfully")

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(db)
	bookHandler := handlers.NewBookHandler(db)

	// Initialize Gin router
	r := gin.Default()

	// CORS middleware
	config := cors.DefaultConfig()
	config.AllowOrigins = []string{"http://localhost:5001", "http://localhost:5002", "http://localhost:3000"}
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	config.AllowHeaders = []string{"Origin", "Content-Type", "Accept", "Authorization"}
	r.Use(cors.New(config))

	// Health check endpoint
	r.GET("/health", bookHandler.HealthCheck)

	// API routes
	api := r.Group("/api/v1")
	{
		// Auth routes (no authentication required)
		auth := api.Group("/auth")
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
			auth.POST("/logout", authHandler.Logout)
		}

		// Protected routes (authentication required)
		protected := api.Group("/")
		protected.Use(authHandler.AuthMiddleware())
		{
			protected.GET("/auth/me", authHandler.GetCurrentUser)
			protected.GET("/books", bookHandler.GetBooks)
			protected.POST("/books", bookHandler.CreateBook)
			protected.PUT("/books/:id/status", bookHandler.UpdateBookStatus)
			protected.DELETE("/books/:id", bookHandler.DeleteBook)
		}
	}

	// Get port from environment or default to 8080
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Starting server on port %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}