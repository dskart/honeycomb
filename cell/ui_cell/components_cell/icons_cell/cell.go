package iconscell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "icons"

	checkTemplFileName      = "check.templ"
	clockTemplFileName      = "clock.templ"
	folderOpenTemplFileName = "folder_open.templ"
	trashTemplFileName      = "trash.templ"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	cellTemplates := []cellbuilder.CellTemplate{
		{
			TemplateName: checkTemplFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, checkTemplFileName),
			Data:         cfg,
		},
		{
			TemplateName: clockTemplFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, clockTemplFileName),
			Data:         cfg,
		},
		{
			TemplateName: folderOpenTemplFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, folderOpenTemplFileName),
			Data:         cfg,
		},
		{
			TemplateName: trashTemplFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, trashTemplFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, cellTemplates); err != nil {
		return err
	}

	return nil
}
