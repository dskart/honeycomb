package configurator

import "fmt"

type StoreConfig struct {
	Type string `toml:"type"`
}

func (sc *StoreConfig) Validate() error {
	if !isStoreTypeValid(string(sc.Type)) {
		return fmt.Errorf("invalid store type: %s", sc.Type)
	}

	return nil
}

func isStoreTypeValid(storeType string) bool {
	switch storeType {
	case "keyvaluestore":
		return true
	default:
		return false
	}
}
