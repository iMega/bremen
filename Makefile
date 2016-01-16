IMAGE = imega/bremen
CONTAINERS = imega_bremen
PORT = -p 80:80

build:
	@docker build -t $(IMAGE) .

start:
	@docker run -d --name imega_bremen \
		$(PORT) \
		$(IMAGE)

stop:
	@-docker stop $(CONTAINERS)

clean: stop
	@-docker rm -fv $(CONTAINERS)

destroy: clean
	@docker rmi -f $(IMAGE)
