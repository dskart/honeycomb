package configurator

import (
	"fmt"
	"os"
	"path"
	"runtime"
	"strings"
)

type HoneycombConfig struct {
	// This gets populated from the cmd arg
	ProjectPath string
	// https://go.dev/ref/mod#glos-module-path
	GoModulePath string `toml:"go_module_path"`
	ProjectName  string `toml:"project_name"`
	GoVersion    string `toml:"go_version"`
	CfgEnvPrefix string `toml:"cfg_env_prefix"`

	Store *StoreConfig `toml:"store"`
	Ui    *UiConfig    `toml:"ui"`
}

func New(projectPath string) (HoneycombConfig, error) {
	configFilePath := path.Join(projectPath, HoneycombConfigFileName)
	if _, err := os.Stat(configFilePath); os.IsNotExist(err) {
		return HoneycombConfig{}, fmt.Errorf("honeycomb.toml file does not exist")
	}

	cfg, err := UnmarshalConfigFromFile(configFilePath)
	if err != nil {
		return HoneycombConfig{}, err
	}

	if err := cfg.Validate(); err != nil {
		return HoneycombConfig{}, err
	}

	cfg.ProjectPath = projectPath
	cfg, err = fillDefaultConfigValues(cfg)
	if err != nil {
		return HoneycombConfig{}, err
	}

	return cfg, nil
}

func (cfg HoneycombConfig) Validate() error {
	if cfg.GoModulePath == "" {
		return fmt.Errorf("go_module_path is required")
	}

	return nil
}

// fillDefaultConfigValues fills in default values for the config
func fillDefaultConfigValues(cfg HoneycombConfig) (HoneycombConfig, error) {
	if cfg.ProjectName == "" {
		cfg.ProjectName = getProjectName(cfg.GoModulePath)
	}

	if cfg.GoVersion == "" {
		goVersion := runtime.Version()
		goVersion = strings.TrimPrefix(goVersion, "go")
		cfg.GoVersion = goVersion
	}

	if cfg.CfgEnvPrefix == "" {
		cfg.CfgEnvPrefix = strings.Replace(strings.ToUpper(cfg.ProjectName), "-", "_", -1)
	}

	return cfg, nil
}

func getProjectName(GoModulePath string) string {
	splitStr := strings.Split(GoModulePath, "/")
	return splitStr[len(splitStr)-1]
}
