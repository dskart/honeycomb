package store

type Config struct {
	// If given, an in-memory store will be used. No data will persist after the process exits, and
	// CLI commands cannot be used to populate the store. This is really only useful for tests.
	InMemory bool `yaml:"InMemory"`

	// If given, Redis will be used for the store. This should be an IP address and port such as
	// "127.0.0.1:6379".
	RedisAddress string `yaml:"RedisAddress"`

	// If given, DynamoDB will be used for the store. Credentials are assumed to be provided via the
	// usual environment variables or an IAM role.
	DynamoDB *DynamoDBConfig `yaml:"DynamoDB"`
}

type DynamoDBConfig struct {
	// The DynamoDB API endpoint. In development, it may be useful to run DynamoDB locally and set
	// this to http://127.0.0.1:8000.
	Endpoint string `yaml:"Endpoint"`

	// The name of the DynamoDB table.
	TableName string `yaml:"TableName"`
}
