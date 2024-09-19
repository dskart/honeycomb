package app

import (
	{{- if .Store}}
	"{{.GoModulePath}}/store"
	{{- end}}
)

type Config struct {
	{{- if .Store}}
	Store store.Config `yaml:"Store"`
	{{- end}}
}

func (c Config) Validate() error {
	return nil
}