ARG GROUP_ID=1001
ARG USER_ID=1001

FROM ubuntu:20.04

SHELL ["/bin/bash", "-c"]

RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
        firefox \
        pulseaudio \
        xorg \
    && rm -rf /var/lib/apt/lists/*

COPY docker_files/entrypoint.sh /entrypoint.sh

ARG GROUP_ID
ARG USER_ID

RUN groupadd -g $GROUP_ID ff \
    && useradd -u $USER_ID -g $GROUP_ID -m ff \
    && chmod ugo+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD []
