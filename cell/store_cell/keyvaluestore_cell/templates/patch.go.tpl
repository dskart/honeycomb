package store

import (
	"fmt"
	"reflect"

	appErrors "{{.GoModulePath}}/pkg/errors"

	"github.com/google/uuid"
)

// When we patch an object, we use optimistic locking. This is the maximum number of times to try
// the patch before erroring out.
const maxOptimisticWriteAttempts = 3

// Returned when a change conflicts with a simultaneous write, e.g. when you attempt to add a
// revision that already exists.
var ErrContention = fmt.Errorf("contention")

type getFunc[T any] func(id uuid.UUID) (*T, appErrors.SanitizedError)
type commitFunc[T any] func(current, prev *T) error
type validateFunc[T any] func(v *T) appErrors.SanitizedError

type PatchOptions[T any] struct {
	Validate validateFunc[T]
}

func WithValidate[T any](validate validateFunc[T]) func(*PatchOptions[T]) {
	return func(o *PatchOptions[T]) {
		o.Validate = validate
	}
}

// Patch is a helper function for patching objects. It handles optimistic locking and retries.
// The type T must implement the Model interface and have a WithPatch method that takes a patch and returns a pointer to the patched object.
func Patch[T any, P any](id uuid.UUID, patch P, get getFunc[T], commit commitFunc[T], opts ...func(*PatchOptions[T])) (newRevision, prevRevision *T, err error) {
	options := PatchOptions[T]{}
	for _, o := range opts {
		o(&options)
	}

	withPatchArgs := []reflect.Value{reflect.ValueOf(patch)}
	for i := 0; i < maxOptimisticWriteAttempts; i++ {
		existing, err := get(id)
		existingValue := reflect.ValueOf(existing)
		if existing == nil {
			return nil, nil, err
		} else {
			// If the patch doesn't change anything, we don't need to do anything.
			equalityTest := existingValue.MethodByName("WithPatch").Call(withPatchArgs)[0]
			equalityTest.Elem().FieldByName("RevisionNumber").Set(existingValue.Elem().FieldByName("RevisionNumber"))
			equalityTest.Elem().FieldByName("RevisionTime").Set(existingValue.Elem().FieldByName("RevisionTime"))
			if reflect.DeepEqual(equalityTest.Interface(), existingValue.Interface()) {
				return existingValue.Interface().(*T), existingValue.Interface().(*T), nil
			}

			newRevision := existingValue.MethodByName("WithPatch").Call(withPatchArgs)[0].Interface().(*T)
			if options.Validate != nil {
				if err := options.Validate(newRevision); err != nil {
					return nil, nil, err
				}
			}

			if err := commit(newRevision, existing); err == ErrContention {
				continue
			} else if err != nil {
				return nil, nil, err
			}
			return newRevision, existing, nil
		}
	}
	return nil, nil, ErrContention
}
