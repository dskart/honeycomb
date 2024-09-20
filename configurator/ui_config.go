package configurator

import "fmt"

type UiConfig struct {
	NodeVersion string `toml:"node_version"`
}

func (uc *UiConfig) Validate() error {
	if uc.NodeVersion == "" {
		return fmt.Errorf("node_version is required")
	}

	return nil
}
