package apicell

import (
	"os"
	"path/filepath"

	pkgcell "github.com/dskart/honeycomb/cell/api_cell/pkg_cell"
	protocell "github.com/dskart/honeycomb/cell/api_cell/proto_cell"
	v1alpha1cell "github.com/dskart/honeycomb/cell/api_cell/v1alpha1_cell"
	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "api"

	apiFileName     = "api.go"
	configFileName  = "config.go"
	swaggerFileName = "swagger.go"

	bufGenFileName  = "buf.gen.yaml"
	bufWorkFileName = "buf.work.yaml"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	if cfg.Api == nil {
		return nil
	}

	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	genPath := filepath.Join(cellPath, "gen")
	if err := os.MkdirAll(genPath, os.ModePerm); err != nil {
		return err
	}

	cellTemplates := []cellbuilder.CellTemplate{
		{
			TemplateName: apiFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, apiFileName),
			Data:         cfg,
		},
		{
			TemplateName: configFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, configFileName),
			Data:         cfg,
		},
		{
			TemplateName: swaggerFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, swaggerFileName),
			Data:         cfg,
		},
		{
			TemplateName: bufGenFileName + ".tpl",
			DestPath:     filepath.Join(parentDir, bufGenFileName),
			Data:         cfg,
		},
		{
			TemplateName: bufWorkFileName + ".tpl",
			DestPath:     filepath.Join(parentDir, bufWorkFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, cellTemplates); err != nil {
		return err
	}

	if err := pkgcell.Build(cfg, cellPath); err != nil {
		return err
	}

	if err := protocell.Build(cfg, cellPath); err != nil {
		return err
	}

	if err := v1alpha1cell.Build(cfg, cellPath); err != nil {
		return err
	}

	return nil
}
