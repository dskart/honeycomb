.tmp
{{.ProjectName}}
{{- if .Store}}
{{- if eq .Store.Type "keyvaluestore"}}
redis_cache
{{- end}}
{{- end}}