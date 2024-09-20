syntax = "proto3";

package {{.ProjectName}}_service.v1alpha1;

import "protoc-gen-openapiv2/options/annotations.proto";

option (grpc.gateway.protoc_gen_openapiv2.options.openapiv2_swagger) = {
  info: {
    title: "{{.ProjectName}} API";
    version: "v1alpha1";
  }

  base_path: "/api/v1alpha1"
  security_definitions: {
    security: {
      key: "ApiKeyAuth";
      value: {
        type: TYPE_API_KEY;
        in: IN_HEADER;
        name: "Authorization";
      }
    }
  }
  security: {
    security_requirement: {key: "ApiKeyAuth"}
  }
  consumes: "application/json";
  produces: "application/json";
};
