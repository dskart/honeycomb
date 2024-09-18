package gomodulecell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "."

	goModFileName = "go.mod"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	cellPath := filepath.Join(parentDir, dirPath)
	err := os.MkdirAll(cellPath, os.ModePerm)
	if err != nil {
		return err
	}

	templates := []cellbuilder.CellTemplate{
		{
			TemplateName: goModFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, goModFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, templates); err != nil {
		return err
	}

	return nil
}
