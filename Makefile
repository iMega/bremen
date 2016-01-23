IMAGE = imega/bremen
CONTAINERS = imega_bremen imega_bremen_db
PORT = -p 80:80
REDIS_PORT = 6379
ENV = PROD
TEST_URL = shopcart.imega.ru/bremen
STORAGE_FOLDER = $(CURDIR)/data
ifeq ($(ENV),"DEV")
	APP_FOLDER = -v $(CURDIR)/app:/app
endif

build:
	@docker build -t $(IMAGE) .

prestart:
	@docker run -d --name imega_bremen_db \
		-v $(STORAGE_FOLDER):/data \
		leanlabs/redis

start:prestart
	@while [ "`docker inspect -f {{.State.Running}} imega_bremen_db`" != "true" ]; do \
		@echo "wait db"; sleep 0.3; \
	done
	$(eval REDIS_IP = $(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' imega_bremen_db))
ifeq ($(ENV),"DEV")
	@docker exec imega_bremen_db \
		sh -c "echo SET auth:9915e49a-4de1-41aa-9d7d-c9a687ec048d 8c279a62-88de-4d86-9b65-527c81ae767a | redis-cli --pipe"
endif
	@docker run -d --name imega_bremen \
		--env REDIS_IP=$(REDIS_IP) \
		--env REDIS_PORT=$(REDIS_PORT) \
		$(APP_FOLDER) \
		-v $(STORAGE_FOLDER):/data \
		$(PORT) \
		$(IMAGE)

stop:
	@-docker stop $(CONTAINERS)

clean: stop
	@-docker rm -fv $(CONTAINERS)

destroy: clean
	@docker rmi -f $(IMAGE)

test:
	@tests/simulator1c.sh $(TEST_URL) "1C+Enterprise/8.3" \
		"9915e49a-4de1-41aa-9d7d-c9a687ec048d:8c279a62-88de-4d86-9b65-527c81ae767a" \
		tests/fixtures/2.04c
