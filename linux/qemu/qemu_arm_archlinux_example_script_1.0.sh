#!/bin/bash

# 2014 (C) Documentation script cgraf 
# Emulating "arm" processors in `qemu'.  

# Get an arm release for raspberry pi
wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.zip

unzip ArchLinuxARM-rpi-latest.zip

mkdir mnt1 mnt2

mount ArchLinuxARM-2014.02-rpi.img -o offset=$((2048 * 512)) mnt1

dd if=/dev/zero  of=rootfs.img bs=1M count=1000

mkfs.ext4 -F rootfs.img 

mount rootfs.img mnt2

cp -r mnt1/* mnt2/

umount mnt*

# Grab a precompiled kernel 
wget -c http://xecdesign.com/downloads/linux-qemu/kernel-qemu

qemu-system-arm \
-M versatilepb      \
-serial stdio       \
-cpu arm1176        \
-kernel kernel-qemu \
-append "root=/dev/sda init=/bin/bash rw" \
-hda rootfs.img


# This is not a fully functional arch install at this point.
# Basically systemd does not work correctly, I am not sure why,
# But it is an easy way to get started trying out arm based systems.
