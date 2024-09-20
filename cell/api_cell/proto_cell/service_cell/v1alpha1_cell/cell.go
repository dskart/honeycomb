package v1alpha1cell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "v1alpha1"

	apiProtoFileName = "api.proto"
	todoFileName     = "todo.proto"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	cellTemplates := []cellbuilder.CellTemplate{
		{
			TemplateName: apiProtoFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, apiProtoFileName),
			Data:         cfg,
		},
		{
			TemplateName: todoFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, todoFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, cellTemplates); err != nil {
		return err
	}

	return nil
}
