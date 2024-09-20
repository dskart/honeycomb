package paginationcell

import (
	"embed"
	"path"
	"text/template"
)

const (
	templatesDir = "templates"
)

var (
	//go:embed templates/*
	templateFiles embed.FS

	tmpls *template.Template
)

func init() {
	var err error
	tmpls, err = template.New("").ParseFS(templateFiles, path.Join(templatesDir, "*.tpl"))
	if err != nil {
		panic(err)
	}
}
