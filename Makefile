SHELL=/bin/bash

DOCKER=podman
CLONED_ARCHLINUX_DOCKER=archlinux-docker

DOCKER_ORGANIZATION=archlinux
DOCKER_IMAGE=base
REBUILD_BASE=

FF_IMAGE=firefox


list:
	@ $(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null \
		| awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
		| sort \
		| egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

build_base_arch:
	@ echo "Attempting to build Arch Linux base image";
	@ if [ ! -d "${CURDIR}/${CLONED_ARCHLINUX_DOCKER}" ]; then \
		echo "Cloning archlinux-docker"; \
		git clone https://github.com/archlinux/archlinux-docker.git "${CURDIR}/${CLONED_ARCHLINUX_DOCKER}"; \
		echo base >> "${CURDIR}/${CLONED_ARCHLINUX_DOCKER}/packages"; \
		cd "${CURDIR}/${CLONED_ARCHLINUX_DOCKER}"; \
		echo "Building ${DOCKER_ORGANIZATION}/${DOCKER_IMAGE}"; \
		${DOCKER} build -t ${DOCKER_ORGANIZATION}/${DOCKER_IMAGE} .; \
	else \
		if [ -n "${REBUILD_BASE}" ] || [ -z "`${DOCKER} images --quiet ${DOCKER_ORGANIZATION}/${DOCKER_IMAGE}`" ]; then \
			cd "${CURDIR}/${CLONED_ARCHLINUX_DOCKER}"; \
			git pull; \
			echo "Building ${DOCKER_ORGANIZATION}/${DOCKER_IMAGE}"; \
			${DOCKER} build -t ${DOCKER_ORGANIZATION}/${DOCKER_IMAGE} .; \
		else \
			echo "Not rebuilding ${DOCKER_ORGANIZATION}/${DOCKER_IMAGE}"; \
		fi; \
	fi;

build_firefox:
	@ echo "Attempting to build Firefox image"
	@ if [ -n "${REBUILD_BASE}" ] || [ -z "`${DOCKER} images --quiet ${FF_IMAGE}`" ]; then \
		$(MAKE) build_base_arch; \
		${DOCKER} build \
			--build-arg ARCH_ARCHIVE_DATE=2020/10/23 \
			-t ${FF_IMAGE} .; \
	else \
		echo "Not rebuilding ${FF_IMAGE}"; \
	fi;

run_firefox:
	@ $(MAKE) build_firefox
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
		localhost/firefox \
			firefox
