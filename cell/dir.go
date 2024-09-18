package cell

import (
	"fmt"
	"os"

	"github.com/dskart/honeycomb/configurator"
)

const filePerm = 0755

func initProjectDir(path string) error {
	if err := os.MkdirAll(path, filePerm); err != nil {
		return err
	}

	ok, err := isDirEmpty(path)
	if err != nil {
		return err
	} else if !ok {
		return fmt.Errorf("directory %s is not empty", path)
	}

	return nil
}

// isDirEmpty checks if a given directory is empty or contains only a file named .honeycomb.toml
func isDirEmpty(dir string) (bool, error) {
	f, err := os.Open(dir)
	if err != nil {
		return false, err
	}
	defer f.Close()

	files, err := os.ReadDir(dir)
	if err != nil {
		return false, err
	}

	if len(files) == 0 {
		return true, nil
	}

	if len(files) == 1 && files[0].Name() == configurator.HoneycombConfigFileName {
		return true, nil
	}

	return false, nil
}
