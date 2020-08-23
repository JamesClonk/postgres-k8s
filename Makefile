.DEFAULT_GOAL := help
SHELL := /bin/bash
APP ?= $(shell basename $$(pwd))
COMMIT_SHA = $(shell git rev-parse HEAD)

.PHONY: help
## help: prints this help message
help:
	@echo "Usage:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

.PHONY: stolon
## stolon: download stolon binaries
stolon:
	@export PATH="$${HOME}/bin:$${PATH}"
	curl -LO https://github.com/sorintlab/stolon/releases/download/v0.16.0/stolon-v0.16.0-linux-amd64.tar.gz
	tar -xzf stolon-v0.16.0-linux-amd64.tar.gz stolon-v0.16.0-linux-amd64/bin/ --strip=1 -C .
	mv bin docker/.

.PHONY: login
## login: login to docker hub
login:
	@export PATH="$${HOME}/bin:$${PATH}"
	if [ -z $${DOCKER_USER} ]; then echo 'DOCKER_USER is undefined'; exit 1; fi
	if [ -z $${DOCKER_PASS} ]; then echo 'DOCKER_PASS is undefined'; exit 1; fi
	@echo $${DOCKER_PASS} | docker login -u $${DOCKER_USER} --password-stdin

.PHONY: build
## build: build docker image
build:
	@export PATH="$${HOME}/bin:$${PATH}"
	docker build -t jamesclonk/${APP}:${COMMIT_SHA} docker/

.PHONY: publish
## publish: build and publish docker image
publish:
	@export PATH="$${HOME}/bin:$${PATH}"
	docker push jamesclonk/${APP}:${COMMIT_SHA}
	docker tag jamesclonk/${APP}:${COMMIT_SHA} jamesclonk/${APP}:latest
	docker push jamesclonk/${APP}:latest

.PHONY: run
## run: run docker image
run:
	@export PATH="$${HOME}/bin:$${PATH}"
	docker run --rm --env-file docker/.dockerenv -p 5432:5432 jamesclonk/${APP}:${COMMIT_SHA}

.PHONY: cleanup
cleanup: docker-cleanup
.PHONY: docker-cleanup
## docker-cleanup: cleans up local docker images and volumes
docker-cleanup:
	docker system prune --volumes -a

.PHONY: pgadmin
## pgadmin: connect to deployed pgadmin dashboard
pgadmin:
	sleep 2 && firefox 'http://127.0.0.1:8888' &
	@kubectl -n postgres port-forward service/postgres-pgadmin 8888:8080

.PHONY: pgweb
## pgweb: connect to deployed pgweb dashboard
pgweb:
	sleep 2 && firefox 'http://127.0.0.1:8888' &
	@kubectl -n postgres port-forward service/postgres-pgweb 8888:8081
