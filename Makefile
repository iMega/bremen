IMAGE = imegateleport/bremen

CONTAINERS = teleport_data \
	teleport_acceptor \
	teleport_fileman

TELEPORT_DATA ?= imega/redis:1.0.0
TELEPORT_DATA_PORT ?= 6379
TELEPORT_DATA_IP ?=

TELEPORT_ACCEPTOR ?= imegateleport/bremen
TELEPORT_ACCEPTOR_PORT ?= -p 8183:80

TELEPORT_FILEMAN ?= imegateleport/tokio

build:
	@docker build -t $(IMAGE) .

push:
	@docker push $(IMAGE):latest

stop:
	@-docker stop $(CONTAINERS)

clean: stop
	@-docker rm -fv $(CONTAINERS)
	@rm -rf build/containers/*

destroy: clean
	@-docker rmi -f $(IMAGE)

discovery_data:
	@while [ "`docker inspect -f {{.State.Running}} teleport_data`" != "true" ]; do \
		echo "wait db"; sleep 0.3; \
	done
	$(eval TELEPORT_DATA_IP = $(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' teleport_data))

build/containers/teleport_acceptor: discovery_data build/containers/teleport_fileman
	@mkdir -p $(shell dirname $@)
	@docker run -d --name teleport_acceptor --restart=always \
		--env REDIS_IP=$(TELEPORT_DATA_IP) \
		--env REDIS_PORT=$(TELEPORT_DATA_PORT) \
		--link teleport_fileman:fileman \
		-v $(CURDIR)/data:/data \
		$(TELEPORT_ACCEPTOR_PORT) \
		$(TELEPORT_ACCEPTOR)
	@touch $@

build/containers/teleport_data:
	@mkdir -p $(shell dirname $@)
	@docker run -d --name teleport_data --restart=always -v $(CURDIR)/data:/data $(TELEPORT_DATA)
	@touch $@

build/containers/teleport_fileman:
	@mkdir -p $(shell dirname $@)
	@docker run -d --name teleport_fileman --restart=always -v $(CURDIR)/data:/data $(TELEPORT_FILEMAN)
	@touch $@

build/containers/teleport_tester:
	@cd tests;docker build -t imegateleport/bremen_tester .

data_folder:
	mkdir -p data/source data/zip data/unzip

test: data_folder build/containers/teleport_data build/containers/teleport_acceptor build/containers/teleport_tester
	@docker exec teleport_data \
		sh -c "echo SET auth:9915e49a-4de1-41aa-9d7d-c9a687ec048d 8c279a62-88de-4d86-9b65-527c81ae767a | redis-cli --pipe"
	@docker run --rm -v $(CURDIR)/tests:/data \
		--link teleport_acceptor:acceptor \
		imegateleport/bremen_tester \
		sh -c './simulator1c.sh acceptor "1C+Enterprise/8.3" "9915e49a-4de1-41aa-9d7d-c9a687ec048d:8c279a62-88de-4d86-9b65-527c81ae767a" fixtures/2.04'
	@if [ ! -f "$(CURDIR)/data/zip/9915e49a-4de1-41aa-9d7d-c9a687ec048d/9915e49a-4de1-41aa-9d7d-c9a687ec048d.zip" ];then \
		exit 1; \
	fi

.PHONY: build
