ARG GROUP_ID=1001
ARG USER_ID=1001

FROM docker.io/techgk/arch:latest AS firefox

RUN pacman -Sy --disable-download-timeout --noconfirm \
        firefox \
        dbus \
        pulseaudio \
        pulseaudio-alsa \
        pulseaudio-bluetooth \
        grep xdg-desktop-portal \
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
# Remove firefox system-wide hidden extensions and folders related to telemetry, download hardened user.js
RUN echo "default-server = unix:/run/user/${USER_ID}/pulse/native" >> /etc/pulse/client.conf \
    && rm -rf /usr/lib/firefox/browser/features/*.xpi \
    && rm -rf /usr/lib/firefox/crashreporter \
    && rm -rf /usr/lib/firefox/minidump-analyzer \
    && rm -rf /usr/lib/firefox/pingsender \
    && wget https://github.com/arkenfox/user.js/archive/refs/tags/90.0.tar.gz -O 90.0.tar.gz \
    && tar -zxf 90.0.tar.gz \
    && echo '//' > /usr/lib/firefox/mozilla.cfg \
    && cat user.js-90.0/user.js | sed -e "s/user_pref/pref/g"  >> /usr/lib/firefox/mozilla.cfg \
    && echo 'pref("general.config.obscure_value", 0);' >> /usr/lib/firefox/defaults/pref/local-settings.js \
    && echo 'pref("general.config.filename", "mozilla.cfg");' >> /usr/lib/firefox/defaults/pref/local-settings.js \
    && echo 'pref("ui.systemUsesDarkTheme", 1);' >> /usr/lib/firefox/defaults/pref/local-settings.js \
    && rm 90.0* && rm -r user.js*

USER ff
ENV HOME=/home/ff \
    XDG_CONFIG_HOME=/home/ff/.config \
    XDG_CACHE_HOME=/home/ff/.cache \
    XDG_DATA_HOME=/home/ff/.local/share
WORKDIR /home/ff

# Create mount parents as ff before Podman mounts the PulseAudio cookie.
# Otherwise the runtime can create .config as root, blocking Firefox profiles.
RUN mkdir -p "$XDG_CONFIG_HOME/pulse" "$XDG_CACHE_HOME" "$XDG_DATA_HOME"

ENTRYPOINT ["dbus-run-session", "--", "/entrypoint.sh"]
CMD []
