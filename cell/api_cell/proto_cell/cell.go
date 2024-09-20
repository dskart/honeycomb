package protocell

import (
	"os"
	"path/filepath"

	servicecell "github.com/dskart/honeycomb/cell/api_cell/proto_cell/service_cell"
	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "proto"

	bufMdFileName   = "buf.md"
	bufYamlFileName = "buf.yaml"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	cellTemplates := []cellbuilder.CellTemplate{
		{
			TemplateName: bufMdFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, bufMdFileName),
			Data:         cfg,
		},
		{
			TemplateName: bufYamlFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, bufYamlFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, cellTemplates); err != nil {
		return err
	}

	if err := servicecell.Build(cfg, cellPath); err != nil {
		return err
	}

	return nil
}
