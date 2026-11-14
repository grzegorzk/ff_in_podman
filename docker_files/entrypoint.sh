#!/bin/bash

set -e

# Fail with a useful diagnostic before Firefox displays a profile error.
if [ ! -d "$HOME" ] || [ ! -w "$HOME" ] || [ ! -x "$HOME" ]; then
    echo "Firefox home directory is missing or inaccessible: $HOME (uid=$(id -u))" >&2
    exit 1
fi

# Recent Firefox versions also need writable XDG configuration and cache paths.
for directory in "${XDG_CONFIG_HOME:-$HOME/.config}" \
                 "${XDG_CACHE_HOME:-$HOME/.cache}" \
                 "${XDG_DATA_HOME:-$HOME/.local/share}"; do
    if ! mkdir -p "$directory" || ! probe=$(mktemp "$directory/.firefox-write-check.XXXXXX"); then
        echo "Firefox cannot write to $directory (uid=$(id -u))" >&2
        ls -ld "$directory" >&2 || true
        exit 1
    fi
    rm -f "$probe"
done

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
exec env TZ=UTC firefox "$@"
