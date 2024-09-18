package configcell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "config"

	configFileName               = "config.go"
	configTestFileName           = "config_test.go"
	unmarshallEnvConfigFileName  = "unmarshall_env_config.go"
	unmarshallFileConfigFileName = "unmarshall_file_config.go"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	cellPath := filepath.Join(parentDir, dirPath)
	err := os.MkdirAll(cellPath, os.ModePerm)
	if err != nil {
		return err
	}

	templates := []cellbuilder.CellTemplate{
		{
			TemplateName: configFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, configFileName),
			Data:         cfg,
		},
		{
			TemplateName: configTestFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, configTestFileName),
			Data:         cfg,
		},
		{
			TemplateName: unmarshallEnvConfigFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, unmarshallEnvConfigFileName),
			Data:         cfg,
		},
		{
			TemplateName: unmarshallFileConfigFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, unmarshallFileConfigFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, templates); err != nil {
		return err
	}

	return nil
}
