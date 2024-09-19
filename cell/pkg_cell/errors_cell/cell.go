package errorscell

import (
	"os"
	"path/filepath"

	cellbuilder "github.com/dskart/honeycomb/cell/cell_builder"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "errors"

	authenticationErrorFileName   = "authentication_error.go"
	authorizationErrorFileName    = "authorization_error.go"
	httpFileName                  = "http.go"
	internalErrorFileName         = "internal_error.go"
	resourceNotFoundErrorFileName = "resource_not_found_error.go"
	sanitizedErrorFileName        = "sanitized_error.go"
	userErrorFileName             = "user_error.go"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	templates := []cellbuilder.CellTemplate{
		{
			TemplateName: authenticationErrorFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, authenticationErrorFileName),
			Data:         cfg,
		},
		{
			TemplateName: authorizationErrorFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, authorizationErrorFileName),
			Data:         cfg,
		},
		{
			TemplateName: httpFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, httpFileName),
			Data:         cfg,
		},
		{
			TemplateName: internalErrorFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, internalErrorFileName),
			Data:         cfg,
		},
		{
			TemplateName: resourceNotFoundErrorFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, resourceNotFoundErrorFileName),
			Data:         cfg,
		},
		{
			TemplateName: sanitizedErrorFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, sanitizedErrorFileName),
			Data:         cfg,
		},
		{
			TemplateName: userErrorFileName + ".tpl",
			DestPath:     filepath.Join(cellPath, userErrorFileName),
			Data:         cfg,
		},
	}

	if err := cellbuilder.BuildCell(tmpls, templates); err != nil {
		return err
	}

	return nil
}
