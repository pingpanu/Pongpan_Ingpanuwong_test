package main

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// This is called Dependency Injection,
// The method function newHandler will receive dependency
// (DB make by SQlite in this case) and make a reference to the functions in this RestAPI

// This design allow this RestAPI to be compatible with several kind of DB in the market (e.g. make it compatible with PostgresQL)
// without needing to modify a lot of codes, this mean that we can test, maintain, and scale-up dev easier
// since it make this code flexible
type Handler struct {
	db *gorm.DB
}

func newHandler(db *gorm.DB) *Handler {
	return &Handler{db}
}

// @Summary List all todos
// @Description Get a list of all todos
// @Produce json
// @Success 200 {array} Todo
// @Router /api/Todos [get]
func (r *Handler) listTodos(c *gin.Context) {
	var todos []Todo

	if result := r.db.Find(&todos); result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": result.Error.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, &todos)
}

// @Summary Create a new todo
// @Description Create a new todo item
// @Accept json
// @Produce json
// @Param todo body main.Todo true "Todo object to be added"
// @Success 201 {object} Todo
// @Failure 400 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/Todos [post]
func (r *Handler) createNewTodo(c *gin.Context) {
	// I designed this function to only receive Title and Detail only to simplify front-end development
	// so Annonymous Todo struct is here to bind Title and Detail
	var Annonymous struct {
		Title  string `json:"title" binding:"required"`
		Detail string `json:"detail"`
	}

	if err := c.ShouldBindJSON(&Annonymous); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	// I transfered Annonymous struct to todo, with automatic assign completed status to false.
	// (no way I would post new todo that already has been done right?)
	todo := Todo{
		Title:     Annonymous.Title,
		Detail:    Annonymous.Detail,
		Completed: false, //automatically assigned new todo to false
	}

	if result := r.db.Create(&todo); result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": result.Error.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, &todo)
}

// @Summary Update an existing todo
// @Description Update a todo item by ID
// @Accept json
// @Produce json
// @Param id path int true "Todo ID to be updated"
// @Param todo body main.Todo true "Todo object to be updated"
// @Success 200 {object} Todo
// @Failure 400 {object} map[string]string
// @Failure 404 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/Todos/{id} [put]
func (r *Handler) editTodo(c *gin.Context) {
	//check if json id is valid
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid ID format",
		})
		return
	}

	//check two things,
	// 1) do the record exist (404 not found?)
	// 2) do the first operation failed (not likely to happened but it can)
	// Noted that the red warning message from GORM will always appeared on console.log,
	// I'm new to Golang so I don't want to disable it right now.
	var todo Todo
	if err := r.db.First(&todo, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound { //Check specifically for "record not found" error
			c.JSON(http.StatusNotFound, gin.H{
				"error": "Todo " + c.Param("id") + " not found",
			})
			return
		}
		//In case it's not record not found, it would be internal server error
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
		return
	}

	// updated struct is still needed as Data Transfer Object to prevent modifying ID of the Todo
	var updated struct {
		Title     string `json:"title"`
		Detail    string `json:"detail"`
		Completed bool   `json:"status"`
	}
	if err := c.ShouldBindJSON(&updated); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	todo.Title = updated.Title
	todo.Detail = updated.Detail
	todo.Completed = updated.Completed

	// save the edited todo, if failed, return 500 internal server error
	if err := r.db.Save(&todo).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, &todo)
}

// @Summary Delete a todo
// @Description Delete a todo item by ID
// @Produce json
// @Param id path int true "Todo ID to be deleted"
// @Success 204 "No Content"
// @Failure 404 {object} map[string]string
// @Failure 500 {object} map[string]string
// @Router /api/Todos/{id} [delete]
func (r *Handler) deleteTodo(c *gin.Context) {
	//check if request is in good shape
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid ID format",
		})
		return
	}

	//return 500 internal server error if the operation failed
	result := r.db.Delete(&Todo{}, id)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": result.Error.Error(),
		})
		return
	}

	//return 404 not found if the requested todo is not exist
	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "Todo " + c.Param("id") + " not found",
		})
	}

	c.Status(http.StatusNoContent)
}
