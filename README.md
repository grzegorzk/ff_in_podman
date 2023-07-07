# Run Firefox in unprivileged podman container

* With audio (assuming host uses pulse)
* With video
* root account not involved

# Why

* Improve host system isolation from potentially harmful code running in the browser
* Make tracking of your internet presence a little bit harder

# Run

IMPORANT - close firefox if it's already running.

If you have podman:

```bash
make build
make run
```

If you prefer docker:

```bash
make build DOCKER=docker
make run DOCKER=docker
```

# Hardening

Firefox will, by default, run with hardened user.js preferences. If you prefer raw firefox settings then run like this:

```bash
make run_no_hardening
```

# Troubleshooting

* If you are using podman and fall into weird issues while running this container please check if your `/etc/containers/seccomp.json` diverted from https://raw.githubusercontent.com/containers/common/main/pkg/seccomp/seccomp.json
To check if seccomp.json might be an issue add `--security-opt seccomp=unconfined` to `podman run` options. It is also possible to use downloaded seccomp.json by adding following to `podman run` options: `--security-opt seccomp=/path/to/the/seccomp.json`

# Thanks

People maintaining ArchLinux:
* https://archlinux.org/
Authors of these ArchWiki pages:
* https://wiki.archlinux.org/title/Firefox
* https://wiki.archlinux.org/title/Firefox/Privacy

Authors of arkenfox user.js
* https://github.com/arkenfox/user.js

Authors of this page:
* http://kb.mozillazine.org/Locking_preferences

Great teams building products I love:
* https://www.mozilla.org
* https://podman.io/
* https://ubuntu.com/

Good souls who like to help others:
* https://gist.github.com/sham1/aa451608775d36fb55ebdbbc955bcb4d
* https://askubuntu.com/questions/972510/how-to-set-alsa-default-device-to-pulseaudio-sound-server-on-docker#answer-976561
* https://stackoverflow.com/questions/28985714/run-apps-using-audio-in-a-docker-container#answer-28985715
* https://unix.stackexchange.com/questions/118811/why-cant-i-run-gui-apps-from-root-no-protocol-specified#answer-118826

Many other giants
