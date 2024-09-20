package v1alpha1

import (
	"context"

	"{{.GoModulePath}}/api/pkg/middleware"
	"{{.GoModulePath}}/app"

	"go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc"
	"go.uber.org/zap"
	grpc_middleware "github.com/grpc-ecosystem/go-grpc-middleware"
	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	"google.golang.org/grpc"
	"google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/protobuf/encoding/protojson"
)

type APIService interface {
	RegisterServiceServer(grpcServer *grpc.Server)
	RegisterServiceHandler(ctx context.Context, gwmux *runtime.ServeMux, conn *grpc.ClientConn) error
}

type API struct {
	App *app.App

	config   Config
	services []APIService

	grpcServer *grpc.Server
	gwmux      *runtime.ServeMux
}

func New(config Config, app *app.App) *API {
	services := []APIService{}

	return &API{
		App: app,

		config:   config,
		services: services,
	}
}

func (api *API) GrpcServer() *grpc.Server {
	return api.grpcServer
}

func (api *API) GwMux() *runtime.ServeMux {
	return api.gwmux
}

func CustomMatcher(key string) (string, bool) {
	switch key {
	case "Authorization":
		return key, true
	default:
		return runtime.DefaultHeaderMatcher(key)
	}
}

func (api *API) RegisterServices(ctx context.Context, logger *zap.Logger, grpcServer *grpc.Server, conn *grpc.ClientConn) error {
	gwmux := runtime.NewServeMux(
		runtime.WithHealthzEndpoint(grpc_health_v1.NewHealthClient(conn)),
		runtime.WithIncomingHeaderMatcher(CustomMatcher),
		runtime.WithMarshalerOption(runtime.MIMEWildcard, &runtime.JSONPb{
			MarshalOptions: protojson.MarshalOptions{EmitUnpopulated: false},
		}),
	)

	// Register grpc services
	api.RegisterServers(grpcServer)
	api.RegisterHandlers(ctx, gwmux, conn)

	api.grpcServer = grpcServer
	api.gwmux = gwmux
	return nil
}

func (api *API) NewGRPCServer() *grpc.Server {
	sessionMiddleware := middleware.NewSessionMiddleware(api.App)
	recoveryMiddleware := middleware.RecoveryMiddleware{}

	grpcServer := grpc.NewServer(
		grpc.UnaryInterceptor(grpc_middleware.ChainUnaryServer(
			otelgrpc.UnaryServerInterceptor(),
			sessionMiddleware.UnaryServerInterceptor(),
			recoveryMiddleware.UnaryServerInterceptor(),
		)),
		grpc.StreamInterceptor(grpc_middleware.ChainStreamServer(
			otelgrpc.StreamServerInterceptor(),
			sessionMiddleware.StreamServerInterceptor(),
			recoveryMiddleware.StreamServerInterceptor(),
		)),
	)

	return grpcServer
}

func (api *API) RegisterServers(grpcServer *grpc.Server) {
	for _, s := range api.services {
		s.RegisterServiceServer(grpcServer)
	}
}

func (api *API) RegisterHandlers(ctx context.Context, gwmux *runtime.ServeMux, conn *grpc.ClientConn) error {
	for _, s := range api.services {
		err := s.RegisterServiceHandler(ctx, gwmux, conn)
		if err != nil {
			return err
		}
	}
	return nil
}
