package store

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"
)

//lint:ignore U1000 placeholder helper function from template
func testEncryptionKey() []byte {
	return []byte{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
}

func NewTestStore(ctx context.Context, t *testing.T) *Store {
	s, err := New(ctx, Config{
		InMemory: true,
	})
	require.NoError(t, err)
	return s
}
