package app

import (
	"fmt"
	"time"

	"{{.GoModulePath}}/model"
	appErrors "{{.GoModulePath}}/pkg/errors"
	"github.com/google/uuid"
)

func (s *Session) CreateTodo(text string) appErrors.SanitizedError {
	newTodo := model.NewTodo(s.UserId(), model.NewTodoInput{
		Text:      text,
		Completed: false,
		Timestamp: time.Now(),
	})
	if err := s.store.AddTodo(newTodo); err != nil {
		return s.InternalError(err)
	}

	return nil
}

func (s *Session) GetAllTodos() ([]*model.Todo, appErrors.SanitizedError) {
	todos, err := s.store.GetAllTodos()
	if err != nil {
		return nil, s.InternalError(err)
	}
	return todos, nil
}

func (s *Session) DeleteTodoById(todoId uuid.UUID) appErrors.SanitizedError {
	if err := s.store.DeleteTodoById(todoId); err != nil {
		return s.InternalError(err)
	}
	return nil
}

func (s *Session) ToggleTodoById(todoId uuid.UUID) appErrors.SanitizedError {
	todos, err := s.store.GetTodosByIds(todoId)
	if err != nil {
		return s.InternalError(err)
	} else if len(todos) == 0 {
		return s.ResourceNotFoundError()
	} else if len(todos) > 1 {
		return s.InternalError(fmt.Errorf("expected 1 todo, got %d", len(todos)))
	}
	todo := todos[0]

	newVal := !todo.Completed
	newTodo := todo.WithPatch(s.UserId(), model.TodoPatch{
		Completed: &newVal,
	})

	if err := s.store.AddTodoRevision(newTodo, todo); err != nil {
		return s.InternalError(err)
	}

	return nil
}
