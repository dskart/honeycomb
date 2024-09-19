.git
.gitignore
.tmp
config.yml
{{.ProjectName}}
Makefile
README.md

{{- if .Store}}
{{- if eq .Store.Type "keyvaluestore"}}
redis_cache
{{- end}}
{{- end}}