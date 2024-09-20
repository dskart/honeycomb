package uicell

import (
	"embed"
	"io/fs"
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "ui"

	loginHtmlFileName       = "login.html"
	swaggerPluginJsFileName = "swagger_plugin.js"
	uiTestFileName          = "ui_test.go"
	uiFileName              = "ui.go"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	if err := writeTestData(cellPath); err != nil {
		return err
	}

	templates := []cellbuilder.CellTemplate{
		{
			TemplateName: loginHtmlFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, loginHtmlFileName),
			Data:         cfg,
		},
		{
			TemplateName: swaggerPluginJsFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, swaggerPluginJsFileName),
			Data:         cfg,
		},
		{
			TemplateName: uiTestFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, uiTestFileName),
			Data:         cfg,
		},
		{
			TemplateName: uiFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, uiFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, templates); err != nil {
		return err
	}

	return nil
}

//go:embed test_data/bar_service/*/*.json
var swaggerStaticFs embed.FS

//go:embed test_data/apidocs.swagger.json
var expectedSwaggerFile string

func writeTestData(parentDir string) error {
	testDataDir := filepath.Join(parentDir, "test_data")
	if err := os.MkdirAll(testDataDir, os.ModePerm); err != nil {
		return err
	}

	err := fs.WalkDir(swaggerStaticFs, ".", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		destPath := filepath.Join(parentDir, path)
		if d.IsDir() {
			if err := os.MkdirAll(destPath, os.ModePerm); err != nil {
				return err
			}
		} else {
			data, err := fs.ReadFile(swaggerStaticFs, path)
			if err != nil {
				return err
			}
			if err := os.WriteFile(destPath, data, os.ModePerm); err != nil {
				return err
			}
		}

		return nil
	})

	if err != nil {
		return err
	}

	return os.WriteFile(filepath.Join(testDataDir, "apidocs.swagger.json"), []byte(expectedSwaggerFile), os.ModePerm)
}
