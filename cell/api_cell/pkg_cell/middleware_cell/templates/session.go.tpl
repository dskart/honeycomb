package middleware

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"net"
	"path"
	"strings"
	"time"

	"{{.GoModulePath}}/app"
	"{{.GoModulePath}}/pkg/logger"

	"go.uber.org/zap"
	grpc_middleware "github.com/grpc-ecosystem/go-grpc-middleware"
	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/peer"
	"google.golang.org/grpc/status"
)

func CtxSession(ctx context.Context) *app.Session {
	return ctx.Value(sessionContextKey).(*app.Session).WithContext(ctx)
}

type SessionMiddleware struct {
	app *app.App
}

func NewSessionMiddleware(app *app.App) SessionMiddleware {
	return SessionMiddleware{
		app: app,
	}
}

// If a service implements the AuthFuncOverride method, it will allow access to the service with an anonymous session.
type AnonymousServiceOverride interface {
	AuthFuncOverride()
}

type contextKey string

const sessionContextKey contextKey = "SessionContextKey"

func (sm *SessionMiddleware) UnaryServerInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		ctx, attributes, err := sm.ApplySessionContext(ctx, info.FullMethod, info.Server)
		if err != nil {
			return nil, err
		}

		var grpcErr error
		var ret any
		defer func() {
			logSession(attributes, grpcErr)
		}()

		ret, grpcErr = handler(ctx, req)
		return ret, grpcErr
	}
}

// grpc gateway streaming middleware interceptor
func (sm *SessionMiddleware) StreamServerInterceptor() grpc.StreamServerInterceptor {
	return func(srv interface{}, stream grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		ctx, attributes, err := sm.ApplySessionContext(stream.Context(), info.FullMethod, srv)
		if err != nil {
			return err
		}

		var grpcErr error
		defer func() {
			logSession(attributes, grpcErr)
		}()

		wrapped := grpc_middleware.WrapServerStream(stream)
		wrapped.WrappedContext = ctx

		grpcErr = handler(srv, wrapped)
		return grpcErr
	}
}

type sessionAttributes struct {
	beginTime  time.Time
	fullMethod string
	session    *app.Session
}

func (sm *SessionMiddleware) ApplySessionContext(ctx context.Context, fullMethod string, server interface{}) (context.Context, sessionAttributes, error) {
	beginTime := time.Now()
	session := sm.app.NewSession(sm.app.Logger()).WithContext(ctx)

	attributes := sessionAttributes{
		beginTime:  beginTime,
		fullMethod: fullMethod,
		session:    session,
	}
	session.WithContext(ctx)

	id := make([]byte, 20)
	if _, err := rand.Read(id); err != nil {
		panic(fmt.Sprintf("failed to generate random request ID: %s", err.Error()))
	}

	requestId := base64.RawURLEncoding.EncodeToString(id)
	remote := grpcRequestIPAddress(ctx)
	session = session.WithLogger(session.Logger().With(
		zap.String("requestId", requestId),
		zap.String("peer.address", remote),
	))


	newCtx := context.WithValue(ctx, sessionContextKey, session)
	return newCtx, attributes, nil
}

func logSession(attributes sessionAttributes, err error) {
	duration := time.Since(attributes.beginTime)
	service := path.Dir(attributes.fullMethod)[1:]
	method := path.Base(attributes.fullMethod)

	// skip healthcheck logs to avoid spamming the logs in datadog
	if method != "Check" {
		var l *zap.Logger
		if attributes.session == nil {
			l, _ = logger.NewLogger(false)
			l.Error("could not get session logger")
		} else {
			l = attributes.session.Logger()
		}
		l = l.With(
			zap.Duration("duration", duration),
			zap.String("grpc.method", method),
			zap.String("grpc.service", service),
			zap.Uint32("grpc.code", uint32(status.Code(err))),
		)
		l.Info(method + " " + service)
	}
}

func grpcRequestIPAddress(ctx context.Context) string {
	mdIn, _ := metadata.FromIncomingContext(ctx)
	var hostname string
	if headerVals := mdIn.Get("x-forwarded-for"); len(headerVals) > 0 {
		hostname = headerVals[0]
	}

	if hostname == "" {
		if p, ok := peer.FromContext(ctx); ok {
			hostname = p.Addr.String()
		}
	}

	hostname = strings.TrimSpace(hostname)
	if host, _, err := net.SplitHostPort(hostname); err == nil && host != "" {
		hostname = host
	}

	return hostname
}