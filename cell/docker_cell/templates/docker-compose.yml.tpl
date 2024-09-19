version: "3"
services:
  {{- if .Store}}
  {{- if eq .Store.Type "keyvaluestore"}}
  redis:
    image: redis:latest
    ports:
      - "6379:6379"
    volumes: 
      - ./redis_cache:/data
   {{- end}}
   {{- end}}
