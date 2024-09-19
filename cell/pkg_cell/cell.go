package pkgcell

import (
	"os"
	"path/filepath"

	configcell "github.com/dskart/honeycomb/cell/pkg_cell/config_cell"
	errorscell "github.com/dskart/honeycomb/cell/pkg_cell/errors_cell"
	loggercell "github.com/dskart/honeycomb/cell/pkg_cell/logger_cell"
	shutdowncell "github.com/dskart/honeycomb/cell/pkg_cell/shutdown_cell"
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

	if err := errorscell.Build(cfg, cellPath); err != nil {
		return err
	}

	if err := configcell.Build(cfg, cellPath); err != nil {
		return err
	}

	if err := loggercell.Build(cfg, cellPath); err != nil {
		return err
	}

	if err := shutdowncell.Build(cfg, cellPath); err != nil {
		return err
	}

	return nil
}
