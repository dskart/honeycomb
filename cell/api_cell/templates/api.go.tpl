package api

import (
	"context"
	"fmt"
	"net/http"

	"{{.GoModulePath}}/api/pkg/health"
	"{{.GoModulePath}}/api/pkg/middleware"
	"{{.GoModulePath}}/api/v1alpha1"
	"{{.GoModulePath}}/app"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/health/grpc_health_v1"

	"github.com/gorilla/mux"
	grpc_middleware "github.com/grpc-ecosystem/go-grpc-middleware"
	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	"go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc"
	"go.uber.org/zap"
)

type GrpcGatewayAPI interface {
	RegisterServices(ctx context.Context, logger *zap.Logger, grpcServer *grpc.Server, conn *grpc.ClientConn) error
	GwMux() *runtime.ServeMux
}

type API struct {
	app *app.App

	V1alpha1 GrpcGatewayAPI
}

func New(config Config, app *app.App) *API {
	return &API{
		app:      app,
		V1alpha1: v1alpha1.New(config.V1alpha1, app),
	}
}

func (api *API) RegisterServices(ctx context.Context, logger *zap.Logger, address string) (*grpc.Server, error) {
	grpcServer := api.newGrpcServer()
	// Setup grpc-gateway
	conn, err := grpcConn(ctx, logger, address)
	if err != nil {
		return nil, fmt.Errorf("grpc dial connection: %w", err)
	}

	grpc_health_v1.RegisterHealthServer(grpcServer, &health.HealthService{})

	if err := api.V1alpha1.RegisterServices(ctx, logger, grpcServer, conn); err != nil {
		return nil, err
	}

	return grpcServer, nil
}

func grpcConn(ctx context.Context, logger *zap.Logger, address string) (*grpc.ClientConn, error) {
	conn, err := grpc.Dial(address, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		if cerr := conn.Close(); cerr != nil {
			return nil, cerr
		}
		return nil, err
	}

	go func() {
		<-ctx.Done()
		if cerr := conn.Close(); cerr != nil {
			logger.Error("cloud not close gprc connection", zap.Error(cerr))
		}
	}()

	return conn, nil
}

func (api *API) newGrpcServer() *grpc.Server {
	sessionMiddleware := middleware.NewSessionMiddleware(api.app)
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

func (api *API) RegisterHandles(mux *mux.Router) error {
	mux.PathPrefix("/api/v1alpha1/").Handler(http.StripPrefix("/api/v1alpha1", api.V1alpha1.GwMux()))
	return nil
}
