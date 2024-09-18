package cmd

import (
	"context"
	"fmt"

	"github.com/dskart/honeycomb/cell"
	"github.com/dskart/honeycomb/configurator"
	"github.com/dskart/honeycomb/pkg/shutdown"
	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(initCmd)
}

var initCmd = &cobra.Command{
	Use:   "init",
	Short: "initialize a new honeycomb project",
	Args:  cobra.MaximumNArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		_, cancel := context.WithCancel(context.Background())
		shutdown.OnShutdown(cancel)

		projectPath := "."
		if len(args) > 0 {
			projectPath = args[0]
		}
		cfg, err := configurator.New(projectPath)
		if err != nil {
			return err
		}

		fmt.Printf("cfg is: %+v\n", cfg)
		if err := cell.BuildAllCells(cfg); err != nil {
			return err
		}
		return nil
	},
}
