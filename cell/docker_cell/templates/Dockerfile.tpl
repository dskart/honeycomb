FROM golang:{{.GoVersion}}-alpine AS build

WORKDIR /go/src/{{.GoModulePath}}
COPY . .

RUN go generate ./...
RUN go build .


FROM golang:{{.GoVersion}}-alpine

WORKDIR /usr/bin

COPY --from=build /go/src/{{.GoModulePath}}/{{.ProjectName}} .
RUN ./{{.ProjectName}} --help > /dev/null

ENTRYPOINT ["/usr/bin/{{.ProjectName}}"]

