package cmd

import (
	"{{.GoModulePath}}/app"
	{{- if .Store}}
	"{{.GoModulePath}}/store"
	{{- end}}
)

const cfgEnvPrefix = "{{.CfgEnvPrefix}}"

type Config struct {
	App app.Config `yaml:"App"`
	{{- if .Store}}
	Store store.Config `yaml:"Store"`
	{{- end}}
}
