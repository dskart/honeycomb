package dockercell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "."

	dockerFileName        = "Dockerfile"
	dockerIgnoreFileName  = ".dockerignore"
	dockerComposeFileName = "docker-compose.yml"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	cellPath := filepath.Join(parentDir, dirPath)
	err := os.MkdirAll(cellPath, os.ModePerm)
	if err != nil {
		return err
	}

	cellTemplates := []cellbuilder.CellTemplate{
		{
			TemplateName: dockerFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, dockerFileName),
			Data:         cfg,
		},
		{
			TemplateName: dockerIgnoreFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, dockerIgnoreFileName),
			Data:         cfg,
		},
		{
			TemplateName: dockerComposeFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, dockerComposeFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, cellTemplates); err != nil {
		return err
	}

	return nil
}
