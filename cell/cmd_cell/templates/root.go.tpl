package cmd

import (
	"context"
	_ "embed"
	"fmt"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"

	"{{.ModuleName}}/pkg/config"
	"{{.ModuleName}}/pkg/logger"
	"{{.ModuleName}}/pkg/shutdown"

	awsCfg "github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
	"github.com/spf13/cobra"
	"go.uber.org/zap"
)

//go:embed banner.txt
var bannerArt string

func init() {
	rootLogger, _ = logger.NewLogger(false)

	rootCmd.CompletionOptions.DisableDefaultCmd = true
	rootCmd.PersistentFlags().BoolP("verbose", "v", false, "make output more verbose")
	rootCmd.PersistentFlags().StringP("config", "c", "", "read configuration from this file")
}

var rootLogger *zap.Logger
var rootConfig Config

var rootCmd = &cobra.Command{
	Use:           filepath.Base(os.Args[0]),
	SilenceErrors: true,
	SilenceUsage:  true,
	PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
		verbose, _ := cmd.Flags().GetBool("verbose")
		rootLogger, _ = logger.NewLogger(verbose)
		shutdown.OnShutdown(func() {
			rootLogger.Sync()
		})

		configFilePath, _ := cmd.Flags().GetString("config")
		cfgOpts := []func(*config.UnmarshalConfigOptions){}
		if configFilePath != "" {
			cfgOpts = append(cfgOpts, config.WithFilePath(configFilePath))
		}

		awsConfig, err := awsCfg.LoadDefaultConfig(context.Background())
		if err != nil {
			return err
		}

		if err := config.UnmarshalConfig(context.Background(), secretsmanager.NewFromConfig(awsConfig), cfgEnvPrefix, &rootConfig, cfgOpts...); err != nil {
			return err
		}

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
