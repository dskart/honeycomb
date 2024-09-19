.tmp
config.yml
bin
{{.ProjectName}}
{{- if .Store}}
{{- if eq .Store.Type "keyvaluestore"}}
redis_cache
{{- end}}
{{- end}}