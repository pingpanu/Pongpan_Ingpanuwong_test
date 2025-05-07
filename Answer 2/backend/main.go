package main

import (
	"log"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"     // swagger embed files
	ginSwagger "github.com/swaggo/gin-swagger" // gin-swagger middleware
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"

	_ "example/backend/docs"
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
	// I'm new to golang, and I followed the instruction from a website that use
	// GORM with sqlite, so I decided to stick to this for now,
	db, err := gorm.Open(sqlite.Open("todo.db"), &gorm.Config{})

	if err != nil {
		log.Fatalf("Failed to connect to the database: %v", err)
	}

	//I want to know if I can add security measure to this db
	db.AutoMigrate(&Todo{})
	newTodo := newHandler(db)

	r := gin.New()

	//Swagger endpoint
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	//API routes
	v1 := r.Group("/api")
	{
		v1.GET("/todos", newTodo.listTodos)
		v1.POST("/todos", newTodo.createNewTodo)
		v1.PUT("/todos/:id", newTodo.editTodo)
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
