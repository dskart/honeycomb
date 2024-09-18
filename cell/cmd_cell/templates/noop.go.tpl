package cmd

import (
	"context"

	"{{.GoModulePath}}/app"
	"{{.GoModulePath}}/pkg/shutdown"

	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(noopCmd)
}

var noopCmd = &cobra.Command{
	Use:   "noop",
	Short: "noop",
	RunE: func(cmd *cobra.Command, args []string) error {
		ctx, cancel := context.WithCancel(context.Background())
		shutdown.OnShutdown(cancel)

		app, err := app.New(ctx, rootLogger, rootConfig.App)
		if err != nil {
			return err
		}
		session := app.NewSession(rootLogger).WithContext(ctx)
		session.Logger().Info("Hello World!")

		return nil
	},
}
