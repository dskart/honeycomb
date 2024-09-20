package middlewarecell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "middleware"

	recoveryFileName = "recovery.go"
	sessionFileName  = "session.go"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {

	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	cellTemplates := []cellbuilder.CellTemplate{
		{
			TemplateName: recoveryFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, recoveryFileName),
			Data:         cfg,
		},
		{
			TemplateName: sessionFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, sessionFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, cellTemplates); err != nil {
		return err
	}

	return nil
}
