package cmd

import (
	"context"
	"fmt"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/dskart/honeycomb/configurator"
	"github.com/dskart/honeycomb/pkg/shutdown"
	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(genHtmlCmd)
}

var genHtmlCmd = &cobra.Command{
	Use:   "init",
	Short: "initialize a new honeycomb project",
	RunE: func(cmd *cobra.Command, args []string) error {
		_, cancel := context.WithCancel(context.Background())
		shutdown.OnShutdown(cancel)

		p := tea.NewProgram(configurator.NewTeaModel())
		model, err := p.Run()
		if err != nil {
			return fmt.Errorf("failed running tea program: %w", err)
		}

		cfg, err := model.(configurator.TeaModel).GetHoneyCombConfig()
		if err != nil {
			return fmt.Errorf("failed getting honeycomb config: %w", err)
		}

		fmt.Printf("cfg is: %+v\n", cfg)
		// if err := cell.BuildAllCells(*cfg); err != nil {
		// 	return err
		// }
		return nil
	},
}
