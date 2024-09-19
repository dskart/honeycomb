package keyvaluestorecell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "."

	storeFileName       = "store.go"
	storeTestFileName   = "store_test.go"
	conditionalFileName = "conditional.go"
	configFileName      = "config.go"
	patchFileName       = "patch.go"
	patchTestFileName   = "patch_test.go"
	serializerFileName  = "serializer.go"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	templates := []cellbuilder.CellTemplate{
		{
			TemplateName: storeFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, storeFileName),
			Data:         cfg,
		},
		{
			TemplateName: storeTestFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, storeTestFileName),
			Data:         cfg,
		},
		{
			TemplateName: conditionalFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, conditionalFileName),
			Data:         cfg,
		},
		{
			TemplateName: configFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, configFileName),
			Data:         cfg,
		},
		{
			TemplateName: patchFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, patchFileName),
			Data:         cfg,
		},
		{
			TemplateName: patchTestFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, patchTestFileName),
			Data:         cfg,
		},
		{
			TemplateName: serializerFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, serializerFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, templates); err != nil {
		return err
	}

	return nil
}
