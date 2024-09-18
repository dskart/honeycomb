package store

import (
	"bytes"
	"compress/gzip"
	"strings"

	"github.com/vmihailenco/msgpack"
)

type Serializer interface {
	Serialize(v interface{}) (string, error)
	Deserialize(s string, dest interface{}) error
}

// To use when values are big.
// This compresses the values but make it impossible to look at
// them raw in the database.
type GzipSerializer struct{}

func NewGzipSerializer() GzipSerializer {
	return GzipSerializer{}
}

func (GzipSerializer) Serialize(v any) (string, error) {
	buf := &bytes.Buffer{}
	w := gzip.NewWriter(buf)
	if err := msgpack.NewEncoder(w).Encode(v); err != nil {
		return "", err
	}
	w.Close()
	return buf.String(), nil
}

func (GzipSerializer) Deserialize(s string, dest any) error {
	r, err := gzip.NewReader(strings.NewReader(s))
	if err != nil {
		return err
	}
	defer r.Close()
	return msgpack.NewDecoder(r).Decode(dest)
}
