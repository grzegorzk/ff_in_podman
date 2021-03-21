ARG GROUP_ID=1001
ARG USER_ID=1001

FROM docker.io/techgk/arch:latest AS firefox

RUN pacman -Sy --disable-download-timeout --noconfirm \
        firefox \
        pulseaudio \
        pulseaudio-alsa \
        pulseaudio-bluetooth \
        xorg-server \
        xorg-apps \
        ffmpeg \
        mesa \
    && rm -rf /var/cache/pacman/pkg/* \
    && /bin/bash /root/skim.sh

ARG GROUP_ID
ARG USER_ID

COPY docker_files/entrypoint.sh /entrypoint.sh

RUN groupadd -g $GROUP_ID ff \
    && useradd -u $USER_ID -g $GROUP_ID -G audio,video -m ff \
    && chmod ugo+x /entrypoint.sh

COPY docker_files/pulse-client.conf /etc/pulse/client.conf
RUN echo "default-server = unix:/run/user/${USER_ID}/pulse/native" >> /etc/pulse/client.conf

USER ff

ENTRYPOINT ["/entrypoint.sh"]
CMD []
