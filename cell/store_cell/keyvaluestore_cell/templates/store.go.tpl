package store

import (
	"context"
	"fmt"
	"log"
	"net/url"
	"reflect"
	"time"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	smithyendpoints "github.com/aws/smithy-go/endpoints"
	"github.com/ccbrown/keyvaluestore"
	"github.com/ccbrown/keyvaluestore/dynamodbstore"
	"github.com/ccbrown/keyvaluestore/keyvaluestorecache"
	"github.com/ccbrown/keyvaluestore/memorystore"
	"github.com/ccbrown/keyvaluestore/redisstore"
	"github.com/go-redis/redis"
	"github.com/google/uuid"
)

type Store struct {
	backend                      keyvaluestore.Backend
	originBackend                keyvaluestore.Backend
	hasEventuallyConsistentReads bool
	hasReadCache                 bool
}

type resolverV2 struct {
	endpoint string
}

func (r *resolverV2) ResolveEndpoint(ctx context.Context, params dynamodb.EndpointParameters) (smithyendpoints.Endpoint, error) {
	if r.endpoint != "" {
		uri, err := url.Parse(r.endpoint)
		if err != nil {
			return smithyendpoints.Endpoint{}, err
		}
		return smithyendpoints.Endpoint{
			URI: *uri,
		}, nil
	}

	return dynamodb.NewDefaultEndpointResolverV2().ResolveEndpoint(ctx, params)
}

func New(ctx context.Context, cfg Config) (*Store, error) {
	if cfg.InMemory {
		return &Store{
			backend: memorystore.NewBackend(),
		}, nil
	}

	if dynamodbCfg := cfg.DynamoDB; dynamodbCfg != nil {
		awsConfig, err := config.LoadDefaultConfig(ctx)
		if err != nil {
			log.Fatalf("failed to load configuration, %v", err)
		}

		client := dynamodb.NewFromConfig(awsConfig, func(o *dynamodb.Options) {
			o.EndpointResolverV2 = &resolverV2{
				endpoint: dynamodbCfg.Endpoint,
			}
		})

		return &Store{
			backend: &dynamodbstore.Backend{
				Context:   ctx,
				Client:    client,
				TableName: dynamodbCfg.TableName,
			},
		}, nil
	} else if cfg.RedisAddress != "" {
		return &Store{
			backend: &redisstore.Backend{
				Client: redis.NewClient(&redis.Options{
					Addr: cfg.RedisAddress,
				}),
			},
		}, nil
	}

	return nil, fmt.Errorf("invalid store configuration")
}

func (s Store) Close() error {
	return nil
}

func (s Store) WithReadCache() *Store {
	if s.hasReadCache {
		return &s
	}
	s.originBackend = s.backend
	s.backend = keyvaluestorecache.NewReadCache(s.backend)
	s.hasReadCache = true
	return &s
}

func backendsWithEventuallyConsistentReads(backend, originBackend keyvaluestore.Backend) (newBackend, newOriginBackend keyvaluestore.Backend) {
	switch backend := backend.(type) {
	case *dynamodbstore.Backend:
		return backend.WithEventuallyConsistentReads(), nil
	case *keyvaluestorecache.ReadCache:
		newOriginBackend, _ := backendsWithEventuallyConsistentReads(originBackend, nil)
		return backend.WithBackend(newOriginBackend).WithEventuallyConsistentReads(), newOriginBackend
	}
	return backend, originBackend
}

func (s Store) WithEventuallyConsistentReads() *Store {
	if s.hasEventuallyConsistentReads {
		return &s
	}
	s.backend, s.originBackend = backendsWithEventuallyConsistentReads(s.backend, s.originBackend)
	s.hasEventuallyConsistentReads = true
	return &s
}

func backendsWithProfiler(backend, originBackend keyvaluestore.Backend, profiler interface{}) (newBackend, newOriginBackend keyvaluestore.Backend) {
	switch backend := backend.(type) {
	case *redisstore.Backend:
		if p, ok := profiler.(redisstore.Profiler); ok {
			return backend.WithProfiler(p), nil
		}
	case *dynamodbstore.Backend:
		if p, ok := profiler.(dynamodbstore.Profiler); ok {
			return backend.WithProfiler(p), nil
		}
	case *keyvaluestorecache.ReadCache:
		newOriginBackend, _ := backendsWithProfiler(originBackend, nil, profiler)
		return backend.WithBackend(newOriginBackend), newOriginBackend
	}
	return backend, originBackend
}

func (s Store) WithProfiler(profiler interface{}) *Store {
	s.backend, s.originBackend = backendsWithProfiler(s.backend, s.originBackend, profiler)
	return &s
}

//lint:ignore U1000 placeholder helper function from template
func (s *Store) getByIds(key string, dest interface{}, serializer Serializer, ids ...uuid.UUID) error {
	batch := s.backend.Batch()
	gets := make([]keyvaluestore.GetResult, 0, len(ids))
	keys := map[string]struct{}{}
	for _, id := range ids {
		key := key + ":" + id.String()
		if _, ok := keys[key]; !ok {
			gets = append(gets, batch.Get(key))
			keys[key] = struct{}{}
		}
	}
	if err := batch.Exec(); err != nil {
		return err
	}

	objType := reflect.TypeOf(dest).Elem().Elem().Elem()
	slice := reflect.ValueOf(dest).Elem()
	for _, get := range gets {
		if v, _ := get.Result(); v != nil {
			obj := reflect.New(objType)
			if err := serializer.Deserialize(*v, obj.Interface()); err != nil {
				return err
			}
			slice = reflect.Append(slice, obj)
		}
	}
	reflect.ValueOf(dest).Elem().Set(slice)
	return nil
}

//lint:ignore U1000 placeholder helper function from template
func stringsToIds(s []string) []uuid.UUID {
	ret := make([]uuid.UUID, len(s))
	for i, id := range s {
		ret[i] = uuid.MustParse(id)
	}
	return ret
}

//lint:ignore U1000 placeholder helper function from template
func execAtomicWrite(op keyvaluestore.AtomicWriteOperation) (bool, error) {
	ok, err := op.Exec()
	if err != nil && keyvaluestore.IsAtomicWriteConflict(err) {
		return false, ErrContention
	}
	return ok, err
}

//lint:ignore U1000 placeholder helper function from template
func timeMicrosecondScore(t time.Time) float64 {
	return float64(t.Unix()*1000000 + int64(t.Nanosecond()/1000))
}
