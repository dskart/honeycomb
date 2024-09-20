package pagination

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"strings"
)

type PageTokenType int

const (
	NextPageToken PageTokenType = iota
	PrevPageToken
)

type PageToken struct {
	Type PageTokenType
	Key  string
}

func NewNextPageToken(key string) PageToken {
	return PageToken{Type: NextPageToken, Key: key}
}

func NewPrevPageToken(key string) PageToken {
	return PageToken{Type: PrevPageToken, Key: key}
}

func (p PageToken) Encode() (string, error) {
	var buf bytes.Buffer
	encoder := base64.NewEncoder(base64.RawURLEncoding, &buf)
	if err := json.NewEncoder(encoder).Encode(p); err != nil {
		err = fmt.Errorf("failed to encode page token: %v", err)
		return "", err
	}
	if err := encoder.Close(); err != nil {
		err = fmt.Errorf("failed to encode page token: %v", err)
		return "", err
	}
	return buf.String(), nil
}

func DecodePageToken(encoded string) (PageToken, error) {
	var ret PageToken
	if err := json.NewDecoder(base64.NewDecoder(base64.RawURLEncoding, strings.NewReader(encoded))).Decode(&ret); err != nil {
		err = fmt.Errorf("failed to decode page token: %v", err)
		return PageToken{}, err
	}

	return ret, nil
}
