package cmdcell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "cmd"

	mergeSwaggerFileName = "merge_swagger.go"
	rootFileName         = "root.go"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	templates := []cellbuilder.CellTemplate{
		{
			TemplateName: mergeSwaggerFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, mergeSwaggerFileName),
			Data:         cfg,
		},
		{
			TemplateName: rootFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, rootFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, templates); err != nil {
		return err
	}

	return nil
}
