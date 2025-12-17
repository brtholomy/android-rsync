#!/bin/bash

# Variables
rsync_ip="127.0.0.1"
port="1873"
android_path_rsync="/"

# Get android arch
arch=$(adb shell getprop ro.product.cpu.abi)
case $arch in
	arm64*|aarch64*)  arch="aarch64"  ;;
	arm*|aarch*)      arch="arm"      ;;
	x86*)             arch="x86"      ;;
esac

# Download pre-built rsync
! [ -f rsync.bin ] && curl --progress-bar -L -o rsync.bin "https://github.com/JBBgameich/rsync-static/releases/download/continuous/rsync-$arch"

# Kill running rsync instances
adb shell killall rsync

# Push rsync
# NOTE: /data/local/tmp/ is accessible by "shell" user, /data/ is root only:
adb push rsync.bin /data/local/tmp/rsync
adb shell chmod +x /data/local/tmp/rsync

# Create rsyncd.conf
# NOTE: removed uid and gid from default conf
# must run rsync from client with --no-perms to avoid preserving UID/GID when copying
echo -e "address = $rsync_ip\nport = $port\n[root]\npath = $android_path_rsync\nuse chroot = false\nread only = false" > rsyncd.conf
adb push rsyncd.conf /data/local/tmp/rsyncd.conf

################
# NOTE: start here for repeat uses:
# Start rsync daemon on the device
adb shell '/data/local/tmp/rsync --daemon --config=/data/local/tmp/rsyncd.conf &'
adb forward tcp:6010 tcp:1873

# then run like this:
# NOTE: no --archive, but uses --times and --recursive to get what we want:
#
# rsync -vP --times --recursive --delete-after --no-perms --stats ~/y/books/ rsync://localhost:6010/root/sdcard/Books/
