syntax = "proto3";

package {{.ProjectName}}_service.v1alpha1;

import "google/api/annotations.proto";
import "google/protobuf/timestamp.proto";
import "protoc-gen-openapiv2/options/annotations.proto";

message Todo {
  string id = 1;
  string text = 2;
  bool completed = 3;
  google.protobuf.Timestamp timestamp = 4;
}

message PostTodoRequest {
  string text = 1;
}

message PostTodoResponse {
  Todo todo = 1;
}

service TodoService {
  rpc PostTodo(PostTodoRequest) returns (PostTodoResponse) {
    option (google.api.http) = {
      post: "/todo"
      body: "*"
    };
    option (grpc.gateway.protoc_gen_openapiv2.options.openapiv2_operation) = {
      summary: "Create a todo";
      description: "Create a todo and return the todo if successfull.";
      operation_id: "PostTodo";
    };
  }
}
