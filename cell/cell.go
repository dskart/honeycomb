package cell

import (
	"fmt"
	"os/exec"

	appcell "github.com/dskart/honeycomb/cell/app_cell"
	cmdcell "github.com/dskart/honeycomb/cell/cmd_cell"
	gitcell "github.com/dskart/honeycomb/cell/git_cell"
	gomodulecell "github.com/dskart/honeycomb/cell/go_module_cell"
	modelcell "github.com/dskart/honeycomb/cell/model_cell"
	pkgcell "github.com/dskart/honeycomb/cell/pkg_cell"
	storecell "github.com/dskart/honeycomb/cell/store_cell"
	"github.com/dskart/honeycomb/configurator"
)

type App struct{}

func New() (*App, error) {
	return &App{}, nil
}

func BuildAllCells(cfg configurator.HoneycombConfig) error {
	projectPath := cfg.ProjectPath

	if err := initProjectDir(projectPath); err != nil {
		return fmt.Errorf("failed to initialize project directory: %w", err)
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

	if err := modelcell.Build(cfg, projectPath); err != nil {
		return fmt.Errorf("failed to build model cell: %w", err)
	}

	if err := storecell.Build(cfg, projectPath); err != nil {
		return fmt.Errorf("failed to build store cell: %w", err)
	}

	if err := gomodulecell.Build(cfg, projectPath); err != nil {
		return fmt.Errorf("failed to build go_module cell: %w", err)
	}

	if err := gitcell.Build(cfg, projectPath); err != nil {
		return fmt.Errorf("failed to build git cell: %w", err)
	}

	if err := runGoModTidy(projectPath); err != nil {
		return fmt.Errorf("failed to run go mod tidy: %w", err)
	}

	return nil
}

func runGoModTidy(projectPath string) error {
	cmd := exec.Command("go", "mod", "tidy")
	cmd.Dir = projectPath
	if err := cmd.Run(); err != nil {
		return err
	}
	return nil
}
