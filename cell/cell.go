package cell

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	appcell "github.com/dskart/honeycomb/cell/app_cell"
	cmdcell "github.com/dskart/honeycomb/cell/cmd_cell"
	gomodulecell "github.com/dskart/honeycomb/cell/go_module_cell"
	pkgcell "github.com/dskart/honeycomb/cell/pkg_cell"
	"github.com/dskart/honeycomb/configurator"
)

type App struct{}

func New() (*App, error) {
	return &App{}, nil
}

func BuildAllCells(cfg configurator.HoneycombConfig) error {
	projectPath := cfg.ProjectPath

	err := os.MkdirAll(projectPath, os.ModePerm)
	if err != nil {
		return err
	}

	if err := cmdcell.Build(cfg, projectPath); err != nil {
		return fmt.Errorf("failed to build cmd cell: %w", err)
	}

	if err := pkgcell.Build(cfg, projectPath); err != nil {
		return fmt.Errorf("failed to build pkg cell: %w", err)
	}

	if err := appcell.Build(cfg, projectPath); err != nil {
		return fmt.Errorf("failed to build app cell: %w", err)
	}

	if err := gomodulecell.Build(cfg, projectPath); err != nil {
		return fmt.Errorf("failed to build go_module cell: %w", err)
	}

	if err := runGoModTidy(projectPath); err != nil {
		return fmt.Errorf("failed to run go mod tidy: %w", err)
	}

	return nil
}

func getProjectName(moduleName string) string {
	splitStr := strings.Split(moduleName, "/")
	return splitStr[len(splitStr)-1]
}

func runGoModTidy(projectPath string) error {
	cmd := exec.Command("go", "mod", "tidy")
	cmd.Dir = projectPath
	if err := cmd.Run(); err != nil {
		return err
	}
	return nil
}
