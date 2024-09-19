all: {{.ProjectName}}

.PHONY: bin/staticcheck
bin/staticcheck: 
	GOBIN=`pwd`/bin go install honnef.co/go/tools/cmd/staticcheck@latest

{{- if .Ui}}
.PHONY: bin/air
bin/air: 
	GOBIN=`pwd`/bin go install github.com/air-verse/air@latest

.PHONY: bin/templ
bin/templ: 
	GOBIN=`pwd`/bin go install github.com/a-h/templ/cmd/templ@latest
{{- end}}

.PHONY: bin
bin: bin/staticcheck {{if .Ui}}bin/air bin/templ{{end}}

.PHONY: {{.ProjectName}}
{{.ProjectName}}:
	go build .

{{- if .Ui}}
.PHONY: browser-sync
browser-sync:
	npx browser-sync start --proxy "localhost:8080" --files "air/main" --no-open

.PHONY: serve
serve: 
	trap 'kill %1;' SIGINT
	npx browser-sync start --logLevel "silent" --proxy "localhost:8080" --files "air/main" --no-open --no-ui & \
    ./bin/air -c .air.toml

.PHONY: update-htmx
update-htmx:
	mkdir -p ./ui/public/static
	wget https://unpkg.com/htmx.org/dist/htmx.min.js -O ./ui/public/static/htmx.min.js

.PHONE: npm-install
npm-install:
	cd ./ui && npm install

.PHONY: build-ui
build-ui:
	./bin/templ generate
	cd ./ui && npm run build

.PHONY: ui
ui: update-htmx npm-install build-ui
{{- end}}

.PHONY: clean
clean: 
	rm {{.ProjectName}}