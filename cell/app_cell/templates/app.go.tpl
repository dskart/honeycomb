package app

import (
	"context"
	"fmt"

	"go.uber.org/zap"
	{{- if .Store}}
	"{{.GoModulePath}}/store"
	{{- end}}
)

type App struct {
	config Config
	logger *zap.Logger

	{{- if .Store}}
	store  *store.Store
	{{- end}}
}

type Options struct {
	{{- if .Store}}
	store  *store.Store
	{{- end}}
}

{{- if .Store}}
func WithStore(store *store.Store) func(*Options) {
	return func(o *Options) {
		o.store = store
	}
}
{{- end}}

func New(ctx context.Context, logger *zap.Logger, config Config, opts ...func(*Options)) (*App, error) {
	options := Options{}
	for _, o := range opts {
		o(&options)
	}

	if err := config.Validate(); err != nil {
		return nil, fmt.Errorf("could not validate app config: %w", err)
	}

	{{- if .Store}}
	if options.store == nil {
		var err error
		options.store, err = store.New(ctx, config.Store)
		if err != nil {
			return nil, fmt.Errorf("could not create store: %w", err)
		}
	}
	{{- end}}

	ret := &App{
		config: config,
		logger: logger,
		{{- if .Store}}
		store:  options.store,
		{{- end}}
	}

	return ret, nil
}

func (a *App) Close(ctx context.Context) error {
	{{- if .Store}}
	if a.store != nil {
		if err := a.store.Close(); err != nil {
			return err
		}
	}
	{{- end}}
	return nil
}

func (a *App) Logger() *zap.Logger {
	return a.logger
}
