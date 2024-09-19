//go:build tools

package tools

import (
	{{- if .Ui}}
	_ "github.com/a-h/templ"
	{{- end}}
)
