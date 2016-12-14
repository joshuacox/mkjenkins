.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make run       - build and run docker container
	@echo ""   2. make build     - build docker container
	@echo ""   3. make clean     - kill and remove docker container
	@echo ""   4. make enter     - execute an interactive bash in docker container
	@echo ""   3. make logs      - follow the logs of docker container

# run a plain container
run: NAME DATADIR TAG PORT rundocker

rundocker: cid

cid:
	$(eval NAME := $(shell cat NAME))
	$(eval DATADIR := $(shell cat DATADIR))
	$(eval TAG := $(shell cat TAG))
	$(eval PORT := $(shell cat PORT))
	mkdir -p $(DATADIR)
	@docker run --name=$(NAME) \
	--cidfile="cid" \
	-d \
	-p $(PORT):8080 \
	-p 5000:5000 \
	-v $(DATADIR):/var/jenkins_home \
	-t $(TAG)

kill:
	-@docker kill `cat cid`

rm-image:
	-@docker rm `cat cid`
	-@rm cid

rm: kill rm-image

clean: rm

enter:
	docker exec -i -t `cat cid` /bin/bash

logs:
	docker logs -f `cat cid`

NAME:
	@while [ -z "$$NAME" ]; do \
		read -r -p "Enter the name you wish to associate with this container [NAME]: " NAME; echo "$$NAME">>NAME; cat NAME; \
	done ;

TAG:
	@while [ -z "$$TAG" ]; do \
		read -r -p "Enter the tag you wish to associate with this container [TAG]: " TAG; echo "$$TAG">>TAG; cat TAG; \
	done ;

PORT:
	@while [ -z "$$PORT" ]; do \
		read -r -p "Enter the PORT you wish to associate with this container [PORT]: " PORT; echo "$$PORT">>PORT; cat PORT; \
	done ;

rmall: rm

DATADIR:
	@while [ -z "$$DATADIR" ]; do \
		read -r -p "Enter the destination of the Apache data directory you wish to associate with this container [DATADIR]: " DATADIR; echo "$$DATADIR">>DATADIR; cat DATADIR; \
	done ;

perms:
	$(eval DATADIR := $(shell cat DATADIR))
	mkdir -p $(DATADIR)
	chown -R 1000 $(DATADIR)
