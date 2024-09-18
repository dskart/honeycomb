package configurator

import "fmt"

type StoreConfig struct {
	Type StoreType `toml:"type"`
}

type StoreType string

func (st *StoreType) UnmarshalText(text []byte) error {
	v := string(text)

	if !IsStoreTypeValid(v) {
		return fmt.Errorf("invalid store type: %s", v)
	}

	*st = StoreType(v)
	return nil
}

func IsStoreTypeValid(storeType string) bool {
	switch storeType {
	case "keyvaluestore":
		return true
	default:
		return false
	}
}
