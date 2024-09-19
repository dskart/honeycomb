package componentscell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	iconscell "github.com/dskart/honeycomb/cell/ui_cell/components_cell/icons_cell"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "components"

	componentRouterFileName = "component_router.go"
	todoFormTemplFileName   = "todo_form.templ"
	todoItemTemplFileName   = "todo_item.templ"
	todoListTemplFileName   = "todo_list.templ"
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
			TemplateName: todoFormTemplFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, todoFormTemplFileName),
			Data:         cfg,
		},
		{
			TemplateName: todoItemTemplFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, todoItemTemplFileName),
			Data:         cfg,
		},
		{
			TemplateName: todoListTemplFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, todoListTemplFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, cellTemplates); err != nil {
		return err
	}

	if err := iconscell.Build(cfg, cellPath); err != nil {
		return err
	}

	return nil
}