FROM archlinux/base

SHELL ["/bin/bash", "-c"]

ARG ARCH_ARCHIVE_DATE=2020/10/23

RUN echo "Server=https://archive.archlinux.org/repos/$ARCH_ARCHIVE_DATE/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist \
    && pacman -Syy --disable-download-timeout --noconfirm wget \
    && sed -i -- 's/#\(XferCommand = \/usr\/bin\/wget \-\-passive\-ftp \-c \-O %o %u\)/\1/g' /etc/pacman.conf \
    && pacman -Sy --disable-download-timeout --noconfirm \
        firefox \
        nvidia \
        pulseaudio \
        pulseaudio-alsa \
        pulseaudio-bluetooth \
        xorg-server \
        xorg-apps \
    && rm -rf /var/cache/pacman/pkg/*
