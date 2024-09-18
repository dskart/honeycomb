package app

import (
	"context"

	"go.uber.org/zap"
)

type App struct {
	config Config
	logger *zap.Logger
}

type Options struct {
}

func New(ctx context.Context, logger *zap.Logger, config Config, opts ...func(*Options)) (*App, error) {
	options := Options{}
	for _, o := range opts {
		o(&options)
	}

	ret := &App{
		config: config,
		logger: logger,
	}

	return ret, nil
}

func (a *App) Close(ctx context.Context) error {
	return nil
}

func (a *App) Logger() *zap.Logger {
	return a.logger
}
