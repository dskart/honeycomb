package uicell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	componentscell "github.com/dskart/honeycomb/cell/ui_cell/components_cell"
	pagescell "github.com/dskart/honeycomb/cell/ui_cell/pages_cell"
	pkgcell "github.com/dskart/honeycomb/cell/ui_cell/pkg_cell"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "ui"

	gitignoreFileName      = ".gitignore"
	nvmrcFileName          = ".nvmrc"
	inputCssFileName       = "input.css"
	packageJsonFileName    = "package.json"
	postcssConfigFileName  = "postcss.config.js"
	tailwindConfigFileName = "tailwind.config.js"
	routesFileName         = "routes.go"
	uiFileName             = "ui.go"

	airFileName = ".air.toml"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	if cfg.Ui == nil {
		return nil
	}

	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	if err := mkPublicDir(cellPath); err != nil {
		return err
	}

	cellTemplates := []cellbuilder.CellTemplate{
		{
			TemplateName: airFileName + ".tpl",
			DestPath:     filepath.Join(parentDir, airFileName),
			Data:         cfg,
		},
		{
			TemplateName: gitignoreFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, gitignoreFileName),
			Data:         cfg,
		},
		{
			TemplateName: nvmrcFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, nvmrcFileName),
			Data:         cfg,
		},
		{
			TemplateName: inputCssFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, inputCssFileName),
			Data:         cfg,
		},
		{
			TemplateName: packageJsonFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, packageJsonFileName),
			Data:         cfg,
		},
		{
			TemplateName: postcssConfigFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, postcssConfigFileName),
			Data:         cfg,
		},
		{
			TemplateName: tailwindConfigFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, tailwindConfigFileName),
			Data:         cfg,
		},
		{
			TemplateName: routesFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, routesFileName),
			Data:         cfg,
		},
		{
			TemplateName: uiFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, uiFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, cellTemplates); err != nil {
		return err
	}

	if err := pkgcell.Build(cfg, cellPath); err != nil {
		return err
	}

	if err := pagescell.Build(cfg, cellPath); err != nil {
		return err
	}

	if err := componentscell.Build(cfg, cellPath); err != nil {
		return err
	}

	return nil
}

func mkPublicDir(cellPath string) error {
	publicDirPath := filepath.Join(cellPath, "public")
	if err := os.MkdirAll(publicDirPath, os.ModePerm); err != nil {
		return err
	}

	staticDirPath := filepath.Join(publicDirPath, "static")
	if err := os.MkdirAll(staticDirPath, os.ModePerm); err != nil {
		return err
	}

	imgDirPath := filepath.Join(publicDirPath, "img")
	if err := os.MkdirAll(imgDirPath, os.ModePerm); err != nil {
		return err
	}

	dataDirPath := filepath.Join(publicDirPath, "data")
	if err := os.MkdirAll(dataDirPath, os.ModePerm); err != nil {
		return err
	}

	return nil
}
