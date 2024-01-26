#!/bin/bash

set -e

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
TZ=UTC firefox
