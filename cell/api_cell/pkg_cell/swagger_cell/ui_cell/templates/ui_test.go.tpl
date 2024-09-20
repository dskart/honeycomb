package ui

import (
	"embed"
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

//go:embed test_data/bar_service/*/*.json
var SwaggerStaticFs embed.FS

//go:embed test_data/apidocs.swagger.json
var ExpectedSwaggerFile string

func TestGenApiDocsJson(t *testing.T) {
	ret, err := GenApiDocsJson(SwaggerStaticFs, "test_data/bar_service/v1alpha1")
	require.NoError(t, err)
	assert.NotEmpty(t, ret)

	var swaggerDoc SwaggerDoc
	err = json.Unmarshal(ret, &swaggerDoc)
	require.NoError(t, err)

	var expectedSwaggerDoc SwaggerDoc
	err = json.Unmarshal([]byte(ExpectedSwaggerFile), &expectedSwaggerDoc)
	require.NoError(t, err)

	assert.Equal(t, expectedSwaggerDoc.Info, swaggerDoc.Info)
	assert.Equal(t, expectedSwaggerDoc.Swagger, swaggerDoc.Swagger)
	assert.Equal(t, expectedSwaggerDoc.BasePath, swaggerDoc.BasePath)
	assert.Equal(t, expectedSwaggerDoc.Consumes, swaggerDoc.Consumes)
	assert.Equal(t, expectedSwaggerDoc.Produces, swaggerDoc.Produces)
	assert.Equal(t, expectedSwaggerDoc.SecurityDefinitions, swaggerDoc.SecurityDefinitions)
	assert.Equal(t, expectedSwaggerDoc.Security, swaggerDoc.Security)

	assert.Len(t, swaggerDoc.Paths, len(expectedSwaggerDoc.Paths))
	assert.Len(t, swaggerDoc.Definitions, len(expectedSwaggerDoc.Definitions))
	for k := range swaggerDoc.Paths {
		_, ok := expectedSwaggerDoc.Paths[k]
		assert.True(t, ok)
	}

	for k := range swaggerDoc.Definitions {
		_, ok := expectedSwaggerDoc.Definitions[k]
		assert.True(t, ok)
	}
}
