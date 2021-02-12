ARG GROUP_ID=1001
ARG USER_ID=1001

ARG ARCH_ARCHIVE_YEAR=2021
ARG ARCH_ARCHIVE_MONTH=02
ARG ARCH_ARCHIVE_DAY=01

ARG ARCH_BOOTSTRAP_VERSION=${ARCH_ARCHIVE_YEAR}.${ARCH_ARCHIVE_MONTH}.${ARCH_ARCHIVE_DAY}
ARG ARCH_BOOTSTRAP_URL=http://pkg.adfinis-sygroup.ch/archlinux/iso/${ARCH_BOOTSTRAP_VERSION}/archlinux-bootstrap-${ARCH_BOOTSTRAP_VERSION}-x86_64.tar.gz

ARG ARCH_ARCHIVE_VERSION=${ARCH_ARCHIVE_YEAR}/${ARCH_ARCHIVE_MONTH}/${ARCH_ARCHIVE_DAY}
ARG ARCH_ARCHIVE_MIRROR=https://archive.archlinux.org/repos/${ARCH_ARCHIVE_VERSION}/\$repo/os/\$arch

FROM alpine:3 AS downloader

RUN apk update \
    && apk add --no-cache \
        curl \
        gnupg

ARG ARCH_BOOTSTRAP_URL
RUN cd /tmp \
    && curl -0 --insecure ${ARCH_BOOTSTRAP_URL} > image.tar.gz \
    && curl -0 --insecure ${ARCH_BOOTSTRAP_URL}.sig > image.tar.gz.sig \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys 9741E8AC \
    && gpg --verify image.tar.gz.sig \
    && tar -xzf image.tar.gz \
    && rm image.tar.gz && rm image.tar.gz.sig


FROM scratch AS bootstrap

COPY --from=downloader /tmp/root.x86_64 /

ARG ARCH_ARCHIVE_MIRROR
RUN echo "Server = ${ARCH_ARCHIVE_MIRROR}" > /etc/pacman.d/mirrorlist \
    && cp /etc/pacman.conf /etc/pacman.conf.bak \
    && awk '{gsub(/SigLevel.*= Required DatabaseOptional/,"SigLevel = Never");gsub(/\[community\]/,"\[community\]\nSigLevel = Never");}1' /etc/pacman.conf.bak > /etc/pacman.conf \
    && pacman -Sy --noconfirm haveged wget sed \
    && cp /etc/pacman.conf.bak /etc/pacman.conf \
    && haveged -w 1024 \
    && pacman-key --init \
    && pacman-key --populate archlinux \
    && mkdir -p /build/var/lib/pacman \
    && sed -i -- 's/#\(XferCommand = \/usr\/bin\/wget \-\-passive\-ftp \-c \-O %o %u\)/\1/g' /etc/pacman.conf \
    && pacman -r /build -Sy --disable-download-timeout --noconfirm base haveged nano


FROM scratch AS arch

COPY --from=bootstrap /build /

ARG ARCH_ARCHIVE_MIRROR
RUN echo "Server = ${ARCH_ARCHIVE_MIRROR}" > /etc/pacman.d/mirrorlist \
    && haveged -w 1024 \
    && pacman-key --init \
    && pacman-key --populate archlinux \
    && pacman -Sy --disable-download-timeout --noconfirm wget \
    && sed -i -- 's/#\(XferCommand = \/usr\/bin\/wget \-\-passive\-ftp \-c \-O %o %u\)/\1/g' /etc/pacman.conf

COPY docker_files/locale.gen /etc/locale.gen
COPY docker_files/locale.conf /etc/locale.conf

RUN locale-gen


FROM arch AS firefox

ARG ARCH_ARCHIVE_MIRROR
RUN echo "Server = ${ARCH_ARCHIVE_MIRROR}" > /etc/pacman.d/mirrorlist \
    && pacman -Sy --disable-download-timeout --noconfirm \
        firefox \
        pulseaudio \
        pulseaudio-alsa \
        pulseaudio-bluetooth \
        xorg-server \
        xorg-apps \
    && rm -rf /var/cache/pacman/pkg/*

COPY docker_files/entrypoint.sh /entrypoint.sh

ARG GROUP_ID
ARG USER_ID

RUN groupadd -g $GROUP_ID ff \
    && useradd -u $USER_ID -g $GROUP_ID -m ff \
    && chmod ugo+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD []
