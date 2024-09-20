package ui

import (
	"embed"
	"encoding/json"
	"fmt"
	"io/fs"
	"log"
	"maps"
	"net/http"
	"net/url"
	"path/filepath"
	"strings"

	httpSwagger "github.com/swaggo/http-swagger"

	"github.com/gorilla/mux"
)

//go:embed swagger_plugin.js
var swaggerPlugin string

//go:embed login.html
var loginHtml string

type SwaggerOptions struct {
	prefix    string
	authorize func(token string) (bool, error)
}

func WithPrefix(prefix string) func(*SwaggerOptions) {
	return func(opts *SwaggerOptions) {
		opts.prefix = prefix
	}
}

// WithAuthorize will add a login page and authorization to the swagger ui
// It will have a login page on /swagger/login
// Paths on /swagger/ui will be protected by the authorize function, The token is passed as a cookie named core_token in the login page
func WithAuthorize(authorize func(token string) (bool, error)) func(*SwaggerOptions) {
	return func(opts *SwaggerOptions) {
		opts.authorize = authorize
	}
}

// New creates a new swagger ui handler
// It will serve the swagger ui on /swagger/ui
// It will serve the swagger json on /swagger/ui/static/apidocs.swagger.json
// staticFs a file system containing the *.swagger.json files
// swaggerServiceDir should be the name of the versionned directory in staticFs containing the swagger.json file for a service
// example "gen/static/core_service/v2alpha1"
func New(mux *mux.Router, staticFs embed.FS, swaggerServiceDirs []string, opts ...func(*SwaggerOptions)) error {
	options := &SwaggerOptions{
		prefix: "/",
	}

	for _, opt := range opts {
		opt(options)
	}

	swaggerPrefix, err := url.JoinPath(options.prefix, "swagger")
	if err != nil {
		return err
	}
	loginPrefix, err := url.JoinPath(swaggerPrefix, "login")
	if err != nil {
		return err
	}

	swaggerRouter := mux.PathPrefix(swaggerPrefix).Subrouter()
	uiRouter := swaggerRouter.PathPrefix("/ui").Subrouter()

	if options.authorize != nil {
		swaggerRouter.HandleFunc("/login", func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "text/html; charset=utf-8")
			w.Write([]byte(loginHtml))
		})

		uiRouter.Use(func(next http.Handler) http.Handler {
			return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				tokenCookie, err := r.Cookie("core_token")
				if err != nil {
					http.Redirect(w, r, loginPrefix, http.StatusSeeOther)
					return
				}

				authorized, err := options.authorize(tokenCookie.Value)
				if err != nil {
					http.Redirect(w, r, loginPrefix, http.StatusSeeOther)
					return
				}

				if authorized {
					next.ServeHTTP(w, r)
					return
				} else {
					http.Redirect(w, r, loginPrefix, http.StatusSeeOther)
					return
				}
			})
		})
	}

	uiRouterPrefix, err := url.JoinPath(swaggerPrefix, "ui/")
	if err != nil {
		return err
	}

	defaultApiDocsPath := ""
	for _, swaggerServiceDir := range swaggerServiceDirs {
		dirs := strings.Split(swaggerServiceDir, "/")
		version := dirs[len(dirs)-1]

		versionPrefix, err := url.JoinPath(uiRouterPrefix, version+"/")
		if err != nil {
			return err
		}

		staticPrefix, err := url.JoinPath(versionPrefix, "static/")
		if err != nil {
			return err
		}

		apiDocsSwagger, err := GenApiDocsJson(staticFs, swaggerServiceDir)
		if err != nil {
			return err
		}

		uiRouter.HandleFunc(fmt.Sprintf("/%s/static/apidocs.swagger.json", version), func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Cache-Control", "no-cache")
			w.Header().Set("Content-Type", "application/json")
			w.Write(apiDocsSwagger)
		})

		apiDocsPath, err := url.JoinPath(staticPrefix, "apidocs.swagger.json")
		if err != nil {
			return err
		}
		defaultApiDocsPath = apiDocsPath
	}

	uiRouter.PathPrefix("/").Handler(httpSwagger.Handler(
		httpSwagger.URL(defaultApiDocsPath),
		httpSwagger.BeforeScript(swaggerPlugin),
		httpSwagger.Plugins([]string{"SwaggerPlugin"}),
		httpSwagger.UIConfig(map[string]string{
			"onComplete": "() => {window.ui.setToken()}",
		}),
		httpSwagger.AfterScript("console.log(`Hello`)"),
	))

	swaggerRouter.NotFoundHandler = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, uiRouterPrefix, http.StatusSeeOther)
	})

	return nil
}

type SwaggerDoc struct {
	Swagger             string         `json:"swagger"`
	Info                SwaggerInfo    `json:"info"`
	BasePath            string         `json:"basePath"`
	Consumes            []string       `json:"consumes"`
	Produces            []string       `json:"produces"`
	Paths               map[string]any `json:"paths"`
	Definitions         map[string]any `json:"definitions"`
	SecurityDefinitions map[string]any `json:"securityDefinitions"`
	Security            []any          `json:"security"`
}

type SwaggerInfo struct {
	Title       string `json:"title"`
	Description string `json:"description"`
	Version     string `json:"version"`
}

func GenApiDocsJson(staticFs fs.FS, dir string) ([]byte, error) {
	files, err := fs.ReadDir(staticFs, dir)
	if err != nil {
		log.Fatal(err)
	}

	swaggerDoc := SwaggerDoc{
		Paths:       make(map[string]any),
		Definitions: make(map[string]any),
	}
	for _, file := range files {
		fileContent, err := fs.ReadFile(staticFs, filepath.Join(dir, file.Name()))
		if err != nil {
			return nil, err
		}

		var currentFileSwaggerDoc SwaggerDoc
		err = json.Unmarshal(fileContent, &currentFileSwaggerDoc)
		if err != nil {
			return nil, err
		}

		switch file.Name() {
		case "apidocs.swagger.json":
			// skip
		case "api.swagger.json":
			swaggerDoc.Swagger = currentFileSwaggerDoc.Swagger
			swaggerDoc.Info = currentFileSwaggerDoc.Info
			swaggerDoc.BasePath = currentFileSwaggerDoc.BasePath
			swaggerDoc.Consumes = currentFileSwaggerDoc.Consumes
			swaggerDoc.Produces = currentFileSwaggerDoc.Produces
			swaggerDoc.SecurityDefinitions = currentFileSwaggerDoc.SecurityDefinitions
			swaggerDoc.Security = currentFileSwaggerDoc.Security
		default:
			maps.Copy(swaggerDoc.Paths, currentFileSwaggerDoc.Paths)
			maps.Copy(swaggerDoc.Definitions, currentFileSwaggerDoc.Definitions)
		}
	}

	finalDocJSON, err := json.Marshal(swaggerDoc)
	if err != nil {
		return nil, err
	}

	return finalDocJSON, nil
}
