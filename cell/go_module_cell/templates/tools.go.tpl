//go:build tools

package tools

import (
	{{- if .Api}}
	_ "google.golang.org/genproto"
	{{- end}}
)
