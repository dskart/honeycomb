App:
  {{- if .Store}}
  Store:
    {{- if eq .Store.Type "keyvaluestore"}}
    # RedisAddress: 127.0.0.1:6379
    InMemory: True
    {{- end}}
  {{- end}}
