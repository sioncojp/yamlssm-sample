REVISION := $(shell git describe --always)
DATE := $(shell date +%Y-%m-%dT%H:%M:%S%z)
LDFLAGS	:= -ldflags="-X \"main.Revision=$(REVISION)\" -X \"main.BuildDate=${DATE}\""

.PHONY: build-cross dist build deps deps/update clean run help

name		:= yamlssm-sample
linux_name	:= $(name)-linux-amd64
darwin_name	:= $(name)-darwin-amd64

build-cross: ## create to build for linux & darwin to bin/
	GOOS=linux GOARCH=amd64 go build -o bin/$(linux_name) $(LDFLAGS) cmd/$(name)/*.go
	GOOS=darwin GOARCH=amd64 go build -o bin/$(darwin_name) $(LDFLAGS) cmd/$(name)/*.go

dist: build-cross ## create .tar.gz linux & darwin to /bin
	cd bin && tar zcvf $(linux_name).tar.gz $(linux_name) && rm -f $(linux_name)
	cd bin && tar zcvf $(darwin_name).tar.gz $(darwin_name) && rm -f $(darwin_name)

build: ## go build
	go build -o bin/$(name) $(LDFLAGS) cmd/$(name)/*.go

test: ## go test
	go test -v $$(go list ./... | grep -v /vendor/)

deps: ## dep ensure
	dep ensure

deps/update: ## dep update
	dep ensure -update

clean: ## remove bin/*
	rm -f bin/*

run: ## go run
	go run cmd/$(name)/$(name).go -c example/config.toml

help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ { printf "\033[36m%-22s\033[0m %s\n", $$1, $$NF }' $(MAKEFILE_LIST)
