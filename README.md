# Run Firefox in unprivileged podman container

* With audio (assuming host uses pulse)
* With video

# Why

* Improve host system isolation from potentially harmful code running in the browser
* Make tracking of your internet presence a little bit harder

# Run

```bash
make build_firefox
make run_firefox
```

# Thanks

People maintaining ArchLinux:
* https://archlinux.org/

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
