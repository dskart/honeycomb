package model

import (
	"time"

	"github.com/google/uuid"
)

type Todo struct {
	Model
	Text      string
	Completed bool
	Timestamp time.Time
}

type NewTodoInput struct {
	Text      string
	Completed bool
	Timestamp time.Time
}

func NewTodo(revisionUserId uuid.UUID, input NewTodoInput) Todo {
	todo := Todo{
		Text:      input.Text,
		Completed: input.Completed,
		Timestamp: input.Timestamp,
	}

	todo.Model = NewModel(revisionUserId)
	return todo
}

type TodoPatch struct {
	Completed *bool
}

func (t Todo) WithPatch(revisionUserId uuid.UUID, patch TodoPatch) *Todo {
	t.RevisionNumber++
	t.RevisionTime = time.Now()
	t.RevisionUserId = revisionUserId
	if patch.Completed != nil {
		t.Completed = *patch.Completed
	}
	return &t
}
