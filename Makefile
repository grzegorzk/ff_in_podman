SHELL=/bin/bash

DOCKER=podman

FF_IMAGE=firefox
UUID=$(shell id -u)
GUID=$(shell id -g)
UNAME=ff

WITH_USERNS=$$(eval [ "podman" == "${DOCKER}" ] && echo "--userns=keep-id")
WITHOUT_HARDENING=

list:
	@ $(MAKE) -pRrq -f Makefile : 2>/dev/null \
		| grep -e "^[^[:blank:]]*:$$\|#.*recipe to execute" \
		| grep -B 1 "recipe to execute" \
		| grep -e "^[^#]*:$$" \
		| sed -e "s/\(.*\):/\1/g" \
		| sort

build:
	@ ${DOCKER} build \
		--build-arg USER_ID=${UUID} \
		--build-arg GROUP_ID=${GUID} \
		--build-arg UNAME=${UNAME} \
		-t ${FF_IMAGE} .;

run:
	@ ${DOCKER} run \
		${WITH_USERNS} \
		--security-opt label=type:container_runtime_t \
		--net=host -d --rm \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v /dev/dri:/dev/dri \
		-v $(HOME)/.Xauthority:/home/${UNAME}/.Xauthority:Z \
		--device /dev/video0 \
		-e DISPLAY \
		-e XAUTHORITY \
		-v ${XAUTHORITY}:${XAUTHORITY} \
		-v $(HOME)/.config/pulse/cookie:/home/${UNAME}/.config/pulse/cookie \
		-v /etc/machine-id:/etc/machine-id \
		-v /run/user/${UUID}/pulse:/run/user/${UUID}/pulse \
		-v /var/lib/dbus:/var/lib/dbus \
		--device /dev/snd \
		-e PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
		-v ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native \
		${WITHOUT_HARDENING} \
		${FF_IMAGE} 

run_no_hardening:
	$(MAKE) -s run WITHOUT_HARDENING='-v "${CURDIR}"/docker_files/empty-local-settings.js:/usr/lib/firefox/defaults/pref/local-settings.js'
