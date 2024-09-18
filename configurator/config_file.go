package configurator

import (
	"os"

	"github.com/BurntSushi/toml"
)

const HoneycombConfigFileName = "honeycomb.toml"

func UnmarshalConfigFromFile(path string) (HoneycombConfig, error) {
	blob, err := os.ReadFile(path)
	if err != nil {
		return HoneycombConfig{}, err
	}

	cfg := HoneycombConfig{}
	_, err = toml.Decode(string(blob), &cfg)
	if err != nil {
		return cfg, err
	}

	return cfg, nil
}
