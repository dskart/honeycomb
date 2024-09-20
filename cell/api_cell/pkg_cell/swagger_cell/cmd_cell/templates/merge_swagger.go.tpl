package cmd

import (
	"encoding/json"
	"os"
	"path"

	"github.com/spf13/cobra"
	"{{.GoModulePath}}/api/pkg/swagger/ui"
)

func init() {
	rootCmd.AddCommand(mergeSwaggerCmd)
}

var mergeSwaggerCmd = &cobra.Command{
	Use:   "merge-swagger",
	Short: "merge a directory of swagger files into a single swagger file",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		dir := args[0]
		dfs := os.DirFS(dir)

		ret, err := ui.GenApiDocsJson(dfs, ".")
		if err != nil {
			return err
		}

		var swaggerDoc ui.SwaggerDoc
		if err = json.Unmarshal(ret, &swaggerDoc); err != nil {
			return err
		}
		output := path.Join(dir, "apidocs.swagger.json")
		if err := os.WriteFile(output, ret, 0644); err != nil {
			return err
		}

		return nil
	},
}
