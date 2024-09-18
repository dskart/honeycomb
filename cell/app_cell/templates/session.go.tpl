package app

import (
	"context"

	"go.uber.org/zap"
)

type Session struct {
	app     *App
	context context.Context
	logger  *zap.Logger
}

func (a *App) NewSession(logger *zap.Logger) *Session {
	return &Session{
		app:     a,
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
