all: honeycomb

.PHONY: bin/staticcheck
bin/staticcheck: 
	GOBIN=`pwd`/bin go install honnef.co/go/tools/cmd/staticcheck@latest

.PHONY: bin
bin: bin/staticcheck

.PHONY: honeycomb
honeycomb:
	go build .

.PHONY: clean
clean: 
	rm honeycomb