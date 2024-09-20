package grpcerror

import (
	"{{.GoModulePath}}/pkg/errors"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// https://www.grpc.io/docs/guides/error/

// Mapping of grpc codes to http errors:
// https://github.com/googleapis/googleapis/blob/master/google/rpc/code.proto
// https://github.com/grpc-ecosystem/grpc-gateway/blob/master/runtime/errors.go

func NewGRPCError(statusCode codes.Code, err error) error {
	return status.Errorf(statusCode, err.Error())
}

func NewGRPCSanitizedError(err errors.SanitizedError) error {
	statusCode := codes.Internal

	switch err.(type) {
	case *errors.ResourceNotFoundError:
		statusCode = codes.NotFound
	case *errors.UserError:
		statusCode = codes.InvalidArgument
	case *errors.AuthorizationError:
		statusCode = codes.PermissionDenied
	}

	return NewGRPCError(statusCode, err)
}
