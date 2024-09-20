version: v1
name: buf.build/{{.Api.BufAccountName}}/{{.ProjectName}}
deps:
  - buf.build/googleapis/googleapis 
  - buf.build/grpc-ecosystem/grpc-gateway
  - buf.build/grpc/grpc

breaking:
  use:
    - FILE
  ignore_unstable_packages: true
lint:
  use:
    - DEFAULT
