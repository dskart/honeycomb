package swaggercell

import (
	"os"
	"path/filepath"

	cmdcell "github.com/dskart/honeycomb/cell/api_cell/pkg_cell/swagger_cell/cmd_cell"
	uicell "github.com/dskart/honeycomb/cell/api_cell/pkg_cell/swagger_cell/ui_cell"
	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "swagger"

	gitignoreFileName = ".gitignore"
	mainFileName      = "main.go"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	if cfg.Ui == nil {
		return nil
	}

	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	templates := []cellbuilder.CellTemplate{
		{
			TemplateName: gitignoreFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, gitignoreFileName),
			Data:         cfg,
		},
		{
			TemplateName: mainFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, mainFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, templates); err != nil {
		return err
	}

	if err := cmdcell.Build(cfg, cellPath); err != nil {
		return err
	}

	if err := uicell.Build(cfg, cellPath); err != nil {
		return err
	}

	return nil
}
