package middleware

import (
	"context"
	"runtime/debug"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type RecoveryMiddleware struct{}

func (m *RecoveryMiddleware) UnaryServerInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (_ interface{}, err error) {
		session := CtxSession(ctx)

		defer func() {
			if r := recover(); r != nil {
				session.Logger().Sugar().Errorf("%v: %s", r, debug.Stack())
				err = status.Errorf(codes.Internal, "internal server error")
			}
		}()

		return handler(ctx, req)
	}
}

func (m *RecoveryMiddleware) StreamServerInterceptor() grpc.StreamServerInterceptor {
	return func(srv interface{}, ss grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) (err error) {
		session := CtxSession(ss.Context())

		defer func() {
			if r := recover(); r != nil {
				session.Logger().Sugar().Error("%v: %s", r, debug.Stack())
				err = status.Errorf(codes.Internal, "internal server error")
			}
		}()

		return handler(srv, ss)
	}
}
