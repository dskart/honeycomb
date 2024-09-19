package app

import (
	"context"

	{{- if .Store}}
	"{{.GoModulePath}}/store"
	{{- end}}

	"go.uber.org/zap"
	"github.com/google/uuid"
)

type Session struct {
	app     *App
	context context.Context
	logger  *zap.Logger
	{{- if .Store}}
	store   *store.Store
	{{- end}}
}

func (a *App) NewSession(logger *zap.Logger) *Session {
	return &Session{
		app:     a,
		{{- if .Store}}
		store: a.store,
		{{- end}}
		context: context.Background(),
		logger:  logger,
	}
}

func (s Session) WithContext(ctx context.Context) *Session {
	s.context = ctx
	return &s
}

func (s *Session) Context() context.Context {
	return s.context
}

func (s Session) WithLogger(logger *zap.Logger) *Session {
	s.logger = logger
	return &s
}

func (s *Session) Logger() *zap.Logger {
	logger := s.logger
	return logger
}

func (s *Session) UserId() uuid.UUID {
	return uuid.Nil
}