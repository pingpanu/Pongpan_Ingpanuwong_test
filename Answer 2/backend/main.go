package main

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	swaggerFiles "github.com/swaggo/files"     // swagger embed files
	ginSwagger "github.com/swaggo/gin-swagger" // gin-swagger middleware
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"

	_ "example/backend/docs"

	_ "github.com/glebarez/go-sqlite"
)

// @title Todo API
// @version 1.0
// @description This is a simple Todo API server.
// @termsOfService http://swagger.io/terms/

// @contact.name API Support
// @contact.url http://www.swagger.io/support
// @contact.email support@swagger.io

// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html

// @schemes http

func main() {
	//get .env variable for sql password
	err := godotenv.Load()
	if err != nil {
		log.Println("Error loading .env file")
	}

	sqlpass := os.Getenv("SQL_PASSWORD")
	log.Printf("API Key loaded: %s", sqlpass)

	//Make struct for output log
	newLogger := logger.New(
		log.New(os.Stdout, "\r\n", log.LstdFlags),
		logger.Config{
			SlowThreshold:             200 * time.Millisecond,
			LogLevel:                  logger.Info,
			IgnoreRecordNotFoundError: true,
			Colorful:                  true,
		},
	)

	// This project is small so I use sqlite for simplicity, I start by embedded db in password,
	// migrate todo struct to db, and send db to a Go method as "Dependency Injection"
	// that would make this RestAPI more flexible.
	db, err := gorm.Open(sqlite.Open(fmt.Sprintf("todo.db?_pragma_key=%s", sqlpass)), &gorm.Config{
		Logger: newLogger,
	})
	if err != nil {
		log.Fatalf("Failed to connect to the database: %v", err)
	}
	db.AutoMigrate(&Todo{})
	newTodo := newHandler(db)

	// gin.New() is only good for learning, but it need Middleware for logging and recovery.
	r := gin.Default()

	// Add CORS middleware to make cross-origin request possible
	// i.e. have Android, IOS, and Chrome request this RestAPI
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"}, // Change "*" to specific domains in production
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	//Swagger endpoint
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	//API routes
	v1 := r.Group("/api")
	{
		v1.GET("/todos", newTodo.listTodos)
		v1.POST("/todos", newTodo.createNewTodo)
		v1.PUT("/todos/:id", newTodo.editTodo)
		v1.PUT("/todos/:id/flip-status", newTodo.flipTodoStatus)
		v1.DELETE("/todos/:id", newTodo.deleteTodo)
	}
	r.Run()
}

type Todo struct {
	// ID of the todo
	// @ID ID
	ID int `json:"id" gorm:"primaryKey;autoIncrement"`
	// Title of the todo
	// @Description Title of the todo
	Title string `json:"title"`
	// Detail of the todo
	// Detail of the todo
	// @Description Detail of the todo
	Detail string `json:"detail"`
	// Status of the todo (true if completed, false otherwise)
	// @Description Status of the todo
	Completed bool `json:"status"`
}
