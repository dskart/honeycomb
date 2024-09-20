package v1alpha1cell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "v1alpha1"

	apiFileName    = "api.go"
	configFileName = "config.go"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	cellTemplates := []cellbuilder.CellTemplate{
		{
			TemplateName: apiFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, apiFileName),
			Data:         cfg,
		},
		{
			TemplateName: configFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, configFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, cellTemplates); err != nil {
		return err
	}

	return nil
}
