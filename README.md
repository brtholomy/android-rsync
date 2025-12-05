# android-rsync

A script to run rsyncd on Android via adb, so that rsync can work like it should.

Downloads a static binary of rsync while checking which architecture the device needs. Pushes this binary to the device, starts rsync in `--daemon` mode, and sets up port forwarding. Then rsync can work with `rsync://localhost:$PORT` as though everything were fine and Android hadn't betrayed the core principle of the UNIX philosophy with this MTP shit.

# prereqs

## adb

On Arch:

```
pacman -S android-tools
```

## USB connection

Device on debug mode.

# usage

Based on [a blog post](https://ptspts.blogspot.de/2015/03/how-to-use-rsync-over-adb-on-android.html) by [Péter Szabó](https://github.com/pts).

Install and start rsync daemon on the device:

`./adb-start-rsyncd.sh`

You can now transfer files from and to the device. To pull your current rsyncd.conf, use this command:

`rsync -vP --progress --stats rsync://localhost:6010/root/data/local/tmp/rsyncd.conf .`

To sync from the local machine to the device, note the use of `--times` and `--recursive` in place of `--archive`, because we have to avoid trying to preserve permission bits:

`rsync -vP --times --recursive --no-perms --stats ~/y/books/ rsync://localhost:6010/root/sdcard/Books/`
