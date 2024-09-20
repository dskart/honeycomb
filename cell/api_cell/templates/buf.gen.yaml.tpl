version: v1
managed:
  enabled: true
  go_package_prefix:
    default: {{.GoModulePath}}/api/gen
    except:
      - buf.build/googleapis/googleapis
      - buf.build/grpc-ecosystem/grpc-gateway
plugins:
  - plugin: buf.build/protocolbuffers/go
    out: api/gen
    opt: paths=source_relative
  - plugin: buf.build/grpc/go
    out: api/gen
    opt: paths=source_relative
  - plugin: buf.build/grpc-ecosystem/gateway
    out: api/gen
    opt:
      - paths=source_relative
      - allow_delete_body=true
  - plugin: buf.build/grpc-ecosystem/openapiv2
    out: api/gen/static
    opt:
      - allow_delete_body=true
