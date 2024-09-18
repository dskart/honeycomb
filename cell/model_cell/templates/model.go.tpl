package model

import (
	"time"

	"github.com/google/uuid"
)

type Model struct {
	Id             uuid.UUID
	CreationTime   time.Time
	RevisionNumber int
	RevisionTime   time.Time
}

func NewModel() Model {
	var model Model
	model.Id = uuid.New()
	model.CreationTime = time.Now()
	model.RevisionNumber = 1
	model.RevisionTime = model.CreationTime
	return model
}
