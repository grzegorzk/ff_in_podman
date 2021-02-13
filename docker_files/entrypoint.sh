#!/bin/bash

set -e

cp -p /root/.Xauthority /home/ff/.Xauthority
chown ff:ff /home/ff/.Xauthority

cp -r -p /root/.config /home/ff/.config
chown -R ff:ff /home/ff/.config

su --login --whitelist-environment="DISPLAY,PULSE_SERVER" ff --command "firefox"
