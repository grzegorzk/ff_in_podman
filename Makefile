SHELL=/bin/bash

DOCKER=podman

FF_IMAGE=firefox


list:
	@ $(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null \
		| awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
		| sort \
		| egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

build_firefox:
	${DOCKER} build \
		--build-arg USER_ID=$(shell id -u) \
		--build-arg GROUP_ID=$(shell id -g) \
		-t ${FF_IMAGE} .;

run_firefox:
	@ ${DOCKER} run \
		--net=host -it --rm --shm-size 2g \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v /dev/dri:/dev/dri \
		-v $(HOME)/.Xauthority:/root/.Xauthority \
		--device /dev/video0 \
		--security-opt=label=type:container_runtime_t \
		-e DISPLAY \
		-v $(HOME)/.config/pulse/cookie:/root/.config/pulse/cookie \
		--device /dev/snd \
		-e PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
		-v ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native \
		localhost/firefox
