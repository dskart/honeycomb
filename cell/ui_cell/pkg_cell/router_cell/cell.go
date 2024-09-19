package routercell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "router"

	componentRouterFileName = "component_router.go"
	handleFuncFileName      = "handle_func.go"
	pageRouterFileName      = "page_router.go"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	cellTemplates := []cellbuilder.CellTemplate{
		{
			TemplateName: componentRouterFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, componentRouterFileName),
			Data:         cfg,
		},
		{
			TemplateName: handleFuncFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, handleFuncFileName),
			Data:         cfg,
		},
		{
			TemplateName: pageRouterFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, pageRouterFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, cellTemplates); err != nil {
		return err
	}

	return nil
}
