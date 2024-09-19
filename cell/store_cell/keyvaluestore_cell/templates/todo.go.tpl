package store

import (
	"math"
	"strconv"

	"{{.GoModulePath}}/model"

	"github.com/google/uuid"
)

func (s *Store) AddTodo(todo model.Todo) error {
	serialized, err := NewGzipSerializer().Serialize(todo)
	if err != nil {
		return err
	}

	tx := s.backend.AtomicWrite()
	tx.Set("todo:"+todo.Id.String(), serialized)
	tx.SetNX("todo_revision:"+todo.Id.String()+":"+strconv.Itoa(todo.RevisionNumber), serialized)
	tx.ZAdd("todos", todo.Id.String(), timeMicrosecondScore(todo.Timestamp))
	if didCommit, err := execAtomicWrite(tx); err != nil {
		return err
	} else if !didCommit {
		return ErrContention
	}
	return err
}

func (s *Store) DeleteTodoById(todoId uuid.UUID) error {
	tx := s.backend.AtomicWrite()
	tx.Delete("todo:" + todoId.String())
	tx.ZRem("todos", todoId.String())
	if didCommit, err := execAtomicWrite(tx); err != nil {
		return err
	} else if !didCommit {
		return ErrContention
	}
	return nil
}

func (s *Store) GetTodosByIds(ids ...uuid.UUID) ([]*model.Todo, error) {
	var ret []*model.Todo
	return ret, s.getByIds("todo", &ret, NewGzipSerializer(), ids...)
}

func (s *Store) GetAllTodos() ([]*model.Todo, error) {
	ids, err := s.backend.ZRangeByScore("todos", math.Inf(-1), math.Inf(1), 0)
	if err != nil {
		return nil, err
	}

	return s.GetTodosByIds(stringsToIds(ids)...)
}

func (s *Store) AddTodoRevision(new *model.Todo, prev *model.Todo) error {
	serialized, err := NewGzipSerializer().Serialize(new)
	if err != nil {
		return err
	}

	tx := s.backend.AtomicWrite()
	tx.DeleteXX("todo_revision:" + new.Id.String() + ":" + strconv.Itoa(new.RevisionNumber-1))
	tx.SetNX("todo_revision:"+new.Id.String()+":"+strconv.Itoa(new.RevisionNumber), serialized)
	tx.Set("todo:"+new.Id.String(), serialized)
	if didCommit, err := execAtomicWrite(tx); err != nil {
		return err
	} else if !didCommit {
		return ErrContention
	}
	return nil
}
