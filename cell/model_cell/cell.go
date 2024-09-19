package modelcell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "model"

	modelFileName = "model.go"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	if !needModelCell(cfg) {
		return nil
	}

	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	templates := []cellbuilder.CellTemplate{
		{
			TemplateName: modelFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, modelFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, templates); err != nil {
		return err
	}

	return nil
}

func needModelCell(cfg configurator.HoneycombConfig) bool {
	//lint:ignore S1008 this will have more values later
	if cfg.Store != nil {
		return true
	}

	return false
}
