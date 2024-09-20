package id

import (
	"fmt"
	"net/url"

	"github.com/google/uuid"
)

func ParseRawID(rawId string) (uuid.UUID, error) {
	unescapedId, err := url.PathUnescape(rawId)
	if err != nil {
		return uuid.Nil, fmt.Errorf("error unescaping ID: %w", err)
	}
	return uuid.Parse(unescapedId)
}

func ParseRawIDs(rawIds []string) ([]uuid.UUID, error) {
	var ids []uuid.UUID
	for _, rawId := range rawIds {
		id, err := ParseRawID(rawId)
		if err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}
	return ids, nil
}
