package pkgcell

import (
	"os"
	"path/filepath"

	middlewarecell "github.com/dskart/honeycomb/cell/ui_cell/pkg_cell/middleware_cell"
	routercell "github.com/dskart/honeycomb/cell/ui_cell/pkg_cell/router_cell"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "pkg"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	if err := middlewarecell.Build(cfg, cellPath); err != nil {
		return err
	}

	if err := routercell.Build(cfg, cellPath); err != nil {
		return err
	}

	return nil
}
