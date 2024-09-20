package servicecell

import (
	"os"
	"path/filepath"

	v1alpha1cell "github.com/dskart/honeycomb/cell/api_cell/proto_cell/service_cell/v1alpha1_cell"
	"github.com/dskart/honeycomb/configurator"
)

func Build(cfg configurator.HoneycombConfig, parentDir string) error {
	dirPath := cfg.ProjectName + "_service"

	cellPath := filepath.Join(parentDir, dirPath)
	if err := os.MkdirAll(cellPath, os.ModePerm); err != nil {
		return err
	}

	if err := v1alpha1cell.Build(cfg, cellPath); err != nil {
		return err
	}

	return nil
}
