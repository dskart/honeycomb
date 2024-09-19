package cmd

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"{{.GoModulePath}}/app"
	"{{.GoModulePath}}/pkg/shutdown"
	"{{.GoModulePath}}/ui"


	"github.com/NYTimes/gziphandler"
	"github.com/gorilla/mux"
	"github.com/rs/cors"
	"github.com/spf13/cobra"
)

func init() {
	serveCmd.Flags().IntP("port", "p", 8080, "the port to listen on")
	rootCmd.AddCommand(serveCmd)
}

var serveCmd = &cobra.Command{
	Use:   "serve",
	Short: "serves the api",
	RunE: func(cmd *cobra.Command, args []string) error {
		ctx, cancel := context.WithCancel(context.Background())
		shutdown.OnShutdown(cancel)

		app, err := app.New(ctx, rootLogger, rootConfig.App)
		if err != nil {
			return fmt.Errorf("could not create app: %w", err)
		}

		port, _ := cmd.Flags().GetInt("port")
		server, err := getServer(app, port)
		if err != nil {
			return fmt.Errorf("failed to create server: %w", err)
		}

		go func() {
			<-ctx.Done()
			if err := server.Shutdown(context.Background()); err != nil {
				rootLogger.Error(err.Error())
			}
		}()

		rootLogger.Sugar().Infof("listening at http://127.0.0.1:%v", port)
		if err := server.ListenAndServe(); err != http.ErrServerClosed {
			return err
		}

		return nil
	},
}

func getServer(app *app.App, port int) (*http.Server, error) {
	mux := mux.NewRouter()
	if err := ui.RegisterHandles(mux, app); err != nil {
		return nil, fmt.Errorf("could not register handles: %w", err)
	}

	// Compress everything over 10MB
	// https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/ServingCompressedFiles.html
	gzip, err := gziphandler.GzipHandlerWithOpts(gziphandler.MinSize(10_000_000))
	if err != nil {
		return nil, fmt.Errorf("could not create gzip handler: %w", err)
	}

	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
		AllowedMethods: []string{"GET", "HEAD", "PATCH", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders: []string{"Authorization", "Content-Type"},
	})

	address := fmt.Sprintf(":%d", port)
	handler := c.Handler(gzip(mux))
	server := &http.Server{
		Addr:        address,
		Handler:     handler,
		ReadTimeout: 2 * time.Minute,
	}

	return server, nil
}
