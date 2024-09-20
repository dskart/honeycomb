package pkgcell

import (
	"os"
	"path/filepath"

	grpcerrorcell "github.com/dskart/honeycomb/cell/api_cell/pkg_cell/grpc_error_cell"
	healthcell "github.com/dskart/honeycomb/cell/api_cell/pkg_cell/health_cell"
	idcell "github.com/dskart/honeycomb/cell/api_cell/pkg_cell/id_cell"
	middlewarecell "github.com/dskart/honeycomb/cell/api_cell/pkg_cell/middleware_cell"
	paginationcell "github.com/dskart/honeycomb/cell/api_cell/pkg_cell/pagination_cell"
	swaggercell "github.com/dskart/honeycomb/cell/api_cell/pkg_cell/swagger_cell"
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

	if err := grpcerrorcell.Build(cfg, cellPath); err != nil {
		return err
	}

	if err := healthcell.Build(cfg, cellPath); err != nil {
		return err
	}

	if err := idcell.Build(cfg, cellPath); err != nil {
		return err
	}

	if err := middlewarecell.Build(cfg, cellPath); err != nil {
		return err
	}

	if err := paginationcell.Build(cfg, cellPath); err != nil {
		return err
	}

	if err := swaggercell.Build(cfg, cellPath); err != nil {
		return err
	}

	return nil
}
