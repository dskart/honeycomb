package cmd

import (
	"{{.GoModulePath}}/app"
)

const cfgEnvPrefix = "{{.CfgEnvPrefix}}"

type Config struct {
	App app.Config `yaml:"App"`
}
