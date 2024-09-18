package cmd

import (
	"context"
	"fmt"

	"{{.ModuleName}}/app"
	"{{.ModuleName}}/pkg/shutdown"

	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(noopCmd)
}

var noopCmd = &cobra.Command{
	Use:   "noop",
	Short: "noop",
	RunE: func(cmd *cobra.Command, args []string) error {
		_, cancel := context.WithCancel(context.Background())
		shutdown.OnShutdown(cancel)

		session.Logger().Info("Hello World!")

		return nil
	},
}
