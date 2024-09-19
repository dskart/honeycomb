package cmdcell

import (
	"os"
	"path/filepath"

	"github.com/common-nighthawk/go-figure"
	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "cmd"

	mainFileName   = "main.go"
	rootFileName   = "root.go"
	configFileName = "config.go"
	noopFileName   = "noop.go"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	cellPath := filepath.Join(parentDir, dirPath)
	mainGoPath := filepath.Join(parentDir, ".")
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	// write banner
	banner := figure.NewFigure(cfg.ProjectName, "", true)
	os.WriteFile(filepath.Join(cellPath, "banner.txt"), []byte(banner.String()), os.ModePerm)

	cellTemplates := []cellbuilder.CellTemplate{
		{
			TemplateName: rootFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, rootFileName),
			Data:         cfg,
		},
		{
			TemplateName: configFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, configFileName),
			Data:         cfg,
		},
		{
			TemplateName: noopFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, noopFileName),
			Data:         cfg,
		},
		{
			TemplateName: mainFileName + ".tpl",
			DestPath:     filepath.Join(mainGoPath, mainFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, cellTemplates); err != nil {
		return err
	}

	return nil
}
