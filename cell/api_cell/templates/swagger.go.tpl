//go:generate go run {{.GoModulePath}}/api/pkg/swagger merge-swagger ./gen/static/{{.ProjectName}}_service/v1alpha1

package api

import "embed"

//go:embed gen/static/{{.ProjectName}}_service/*/*.json
var SwaggerStaticFs embed.FS

const (
	V1alpha1SwaggerServiceDir = "gen/static/{{.ProjectName}}_service/v1alpha1"
)
