SHELL=/bin/bash

DOCKER=podman

DAY=01
MONTH=$(shell date +%m)
YEAR=$(shell date +%Y)

FF_IMAGE=firefox
UUID=$(shell id -u)
GUID=$(shell id -g)

WITH_USERNS=$$(eval [ "podman" == "${DOCKER}" ] && echo "--userns=keep-id")

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
		--build-arg ARCH_ARCHIVE_YEAR=${YEAR} \
		--build-arg ARCH_ARCHIVE_MONTH=${MONTH} \
		--build-arg ARCH_ARCHIVE_DAY=${DAY} \
		-t ${FF_IMAGE} .;

run:
	@ ${DOCKER} run \
		${WITH_USERNS} \
		--net=host -it --rm \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v /dev/dri:/dev/dri \
		-v $(HOME)/.Xauthority:/home/ff/.Xauthority \
		--device /dev/video0 \
		-e DISPLAY \
		-v $(HOME)/.config/pulse/cookie:/home/ff/.config/pulse/cookie \
		-v /etc/machine-id:/etc/machine-id \
		-v /run/user/${UUID}/pulse:/run/user/${UUID}/pulse \
		-v /var/lib/dbus:/var/lib/dbus \
		--device /dev/snd \
		-e PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
		-v ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native \
		${FF_IMAGE}
