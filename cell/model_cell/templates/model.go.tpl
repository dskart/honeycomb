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
	RevisionUserId uuid.UUID
}

func NewModel(revisionUserId uuid.UUID) Model {
	var model Model
	model.Id = uuid.New()
	model.CreationTime = time.Now()
	model.RevisionNumber = 1
	model.RevisionTime = model.CreationTime
	return model
}

