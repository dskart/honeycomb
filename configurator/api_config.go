package configurator

import "fmt"

type ApiConfig struct {
	Type           string `toml:"type"`
	BufAccountName string `toml:"buf_account_name"`
}

func (ac *ApiConfig) Validate() error {
	if !isApiValidType(string(ac.Type)) {
		return fmt.Errorf("invalid api type: %s", ac.Type)
	}

	if ac.BufAccountName == "" {
		return fmt.Errorf("buf_account_name is required")
	}

	return nil
}
func isApiValidType(apiType string) bool {
	switch apiType {
	case "grpc-gateway":
		return true
	default:
		return false
	}
}
