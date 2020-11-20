#!/bin/bash

set -e

cp -p /root/.Xauthority /home/ff/.Xauthority
chown ff:ff /home/ff/.Xauthority

cp -r -p /root/.config /home/ff/.config
chown -R ff:ff /home/ff/.Xauthority

su ff --command "firefox"
