package appcell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "app"

	appFileName     = "app.go"
	configFileName  = "config.go"
	sessionFileName = "session.go"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	cellPath := filepath.Join(parentDir, dirPath)
	err := os.MkdirAll(cellPath, os.ModePerm)
	if err != nil {
		return err
	}

	templates := []cellbuilder.CellTemplate{
		{
			TemplateName: appFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, appFileName),
			Data:         cfg,
		},
		{
			TemplateName: configFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, configFileName),
			Data:         cfg,
		},
		{
			TemplateName: sessionFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, sessionFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, templates); err != nil {
		return err
	}

	return nil
}
