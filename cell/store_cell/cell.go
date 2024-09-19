package storecell

import (
	"os"
	"path/filepath"

	keyvaluestorecell "github.com/dskart/honeycomb/cell/store_cell/keyvaluestore_cell"
	"github.com/dskart/honeycomb/configurator"
)

const (
	dirPath = "store"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	if cfg.Store == nil {
		return nil
	}

	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	if err := keyvaluestorecell.Build(cfg, cellPath); err != nil {
		return err
	}

	return nil
}
