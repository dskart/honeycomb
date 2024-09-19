package cmd

import (
	_ "embed"
	"fmt"
	"os"
	"os/signal"
	"strings"
	"syscall"

	"github.com/dskart/honeycomb/pkg/logger"
	"github.com/dskart/honeycomb/pkg/shutdown"
	"github.com/spf13/cobra"
	"go.uber.org/zap"
)

//go:embed banner.txt
var bannerArt string

//go:embed version.md
var versionFile string

func version() string {
	return strings.Split(versionFile, " ")[1]
}

func init() {
	rootLogger, _ = logger.NewLogger(false)

	rootCmd.CompletionOptions.DisableDefaultCmd = true
	rootCmd.PersistentFlags().BoolP("verbose", "v", false, "make output more verbose")
}

var rootLogger *zap.Logger

var rootCmd = &cobra.Command{
	Use:           "honeycomb",
	Version:       version(),
	SilenceErrors: true,
	SilenceUsage:  true,
	PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
		verbose, _ := cmd.Flags().GetBool("verbose")
		rootLogger, _ = logger.NewLogger(verbose)
		shutdown.OnShutdown(func() {
			rootLogger.Sync()
		})

		// wait forever for sig signal
		go func() {
			WaitForTermSignal()
		}()

		fmt.Println(bannerArt)

		return nil
	},
	PersistentPostRunE: func(cmd *cobra.Command, args []string) error {
		// Do a graceful shutdown
		shutdown.Shutdown()
		return nil
	},
}

func WaitForTermSignal() {
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGTERM, syscall.SIGQUIT, syscall.SIGINT)

	sig := <-sigs
	rootLogger.Info("received signal, shutting down", zap.String("signal", sig.String()))

	// Do a graceful shutdown
	shutdown.Shutdown()
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		rootLogger.Fatal(err.Error())
	}
}
