package pagination

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestPageToken(t *testing.T) {
	t.Run("NextPageToken", func(t *testing.T) {
		token := NewNextPageToken("key")
		encoded, err := token.Encode()
		require.NoError(t, err)
		decoded, err := DecodePageToken(encoded)
		require.NoError(t, err)
		require.Equal(t, token, decoded)
		require.Equal(t, NextPageToken, token.Type)
	})

	t.Run("PrevPageToken", func(t *testing.T) {
		token := NewPrevPageToken("key")
		encoded, err := token.Encode()
		require.NoError(t, err)
		decoded, err := DecodePageToken(encoded)
		require.NoError(t, err)
		require.Equal(t, token, decoded)
		require.Equal(t, PrevPageToken, token.Type)
	})
}
