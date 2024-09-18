package config

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
)

type UnmarshalConfigOptions struct {
	filePath string
}

// UnmarshalConfig populates config with values from environment variables and a yaml file.
func UnmarshalConfig(ctx context.Context, smClient *secretsmanager.Client, prefix string, config any, opts ...func(*UnmarshalConfigOptions)) error {
	err := UnmarshalConfigFromFile(config, opts...)
	if err != nil {
		return err
	}

	err = UnmarshalConfigFromEnv(ctx, smClient, prefix, config)
	if err != nil {
		return err
	}

	return nil
}
