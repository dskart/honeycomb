package paginationcell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "pagination"

	paginationFileName     = "pagination.go"
	paginationTestFileName = "pagination_test.go"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {

	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	cellTemplates := []cellbuilder.CellTemplate{
		{
			TemplateName: paginationFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, paginationFileName),
			Data:         cfg,
		},
		{
			TemplateName: paginationTestFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, paginationTestFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, cellTemplates); err != nil {
		return err
	}

	return nil
}
