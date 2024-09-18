package cellbuilder

import (
	"fmt"
	"os"
	"text/template"
)

type CellTemplate struct {
	TemplateName string
	DestPath     string
	Data         any
}

func BuildCell(tmpls *template.Template, cellTemplates []CellTemplate) error {
	for _, ct := range cellTemplates {
		f, err := os.Create(ct.DestPath)
		if err != nil {
			return fmt.Errorf("failed to create %s file: %w", ct.DestPath, err)
		}

		if err := tmpls.ExecuteTemplate(f, ct.TemplateName, ct.Data); err != nil {
			return fmt.Errorf("failed to execute %s template: %w", ct.DestPath, err)
		}
	}

	return nil
}
