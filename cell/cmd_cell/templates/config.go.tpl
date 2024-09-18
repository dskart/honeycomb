package cmd

import (
	"{{.ModuleName}}/app"
)

const cfgEnvPrefix = "{{.CfgEnvPrefix}}"

type Config struct {
	App app.Config `yaml:"App"`
}
