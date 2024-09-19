package pagescell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	componentscell "github.com/dskart/honeycomb/cell/ui_cell/pages_cell/components_cell"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "pages"

	pageRouterFileName   = "page_router.go"
	pageTemplateFileName = "page.templ"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	cellTemplates := []cellbuilder.CellTemplate{
		{
			TemplateName: pageRouterFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, pageRouterFileName),
			Data:         cfg,
		},
		{
			TemplateName: pageTemplateFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, pageTemplateFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, cellTemplates); err != nil {
		return err
	}

	if err := componentscell.Build(cfg, cellPath); err != nil {
		return err
	}

	return nil
}
