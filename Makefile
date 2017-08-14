IMAGE = imegateleport/bremen

TELEPORT_DATA_PORT ?= 6379
TELEPORT_ACCEPTOR_PORT ?= -p 8183:80

CON_DIR = build/containers
SRV = data fileman acceptor
SRV_OBJ = $(addprefix $(CON_DIR)/teleport_,$(SRV))

release:
	@docker login --username $(DOCKER_USER) --password $(DOCKER_PASS)
	@docker push $(IMAGE)

build:
	@docker build -t $(IMAGE) .

stop: get_containers
	@-docker stop $(CONTAINERS)

clean: stop
	@-docker rm -fv $(CONTAINERS)
	@rm -rf $(CURDIR)/build

get_containers:
	$(eval CONTAINERS := $(subst $(CON_DIR)/,,$(shell find $(CON_DIR) -type f)))

discovery_data:
	@while [ "`docker inspect -f {{.State.Running}} teleport_data`" != "true" ]; do \
		echo "wait db"; sleep 0.3; \
	done
	$(eval TELEPORT_DATA_IP = $(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' teleport_data))

$(CON_DIR)/teleport_acceptor: discovery_data
	@mkdir -p $(shell dirname $@)
	@touch $@
	@docker run -d --name teleport_acceptor \
		--env REDIS_IP=$(TELEPORT_DATA_IP) \
		--env REDIS_PORT=$(TELEPORT_DATA_PORT) \
		--link teleport_fileman:fileman \
		-v $(CURDIR)/data:/data \
		$(TELEPORT_ACCEPTOR_PORT) \
		imegateleport/bremen

$(CON_DIR)/teleport_data:
	@mkdir -p $(shell dirname $@)
	@touch $@
	@docker run -d --name teleport_data -v $(CURDIR)/data:/data imega/redis

$(CON_DIR)/teleport_fileman:
	@mkdir -p $(shell dirname $@)
	@touch $@
	@docker run -d --name teleport_fileman \
		-p 873:873 \
		-v $(CURDIR)/data:/data \
		-v $(CURDIR)/tests/rsyncd.conf:/etc/rsyncd.conf \
		-v $(CURDIR)/tests/wait-list.txt:/app/wait-list.txt \
		alpine sh -c 'apk --upd --no-cache add rsync && /usr/bin/rsync --no-detach --daemon --config /etc/rsyncd.conf'

data_dir:
	@mkdir -p $(CURDIR)/data/source $(CURDIR)/data/zip $(CURDIR)/data/unzip

test: build data_dir $(SRV_OBJ)
	docker exec teleport_data \
		sh -c 'echo "SET auth:9915e49a-4de1-41aa-9d7d-c9a687ec048d 8c279a62-88de-4d86-9b65-527c81ae767a" | redis-cli --pipe'
	docker run --rm -v $(CURDIR)/tests:/data \
		-w /data \
		--link teleport_acceptor:acceptor \
		alpine sh -c 'apk add --no-cache curl bash zip && \
			./simulator1c.sh acceptor "1C+Enterprise/8.3" "9915e49a-4de1-41aa-9d7d-c9a687ec048d:8c279a62-88de-4d86-9b65-527c81ae767a" fixtures/2.04'
	if [ ! -f "$(CURDIR)/data/zip/9915e49a-4de1-41aa-9d7d-c9a687ec048d/9915e49a-4de1-41aa-9d7d-c9a687ec048d.zip" ];then \
		exit 1; \
	fi
