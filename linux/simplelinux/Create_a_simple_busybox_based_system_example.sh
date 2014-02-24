#!/bin/sh

# 2014 (c) Documentation script, Statix, cgraf 
# Build a very simple linux system all from source code.
# The end system will be fairly capable, and have a simple
# init system and login prompt. After logging in as "root"
# you can set the password
# This example does not cover cross compiling.



y="$(pwd)"
x="${y}/build" 
mkdir -p "${x}" 
JOBZ="-j$(grep -c ^processor /proc/cpuinfo)" 


get_linux()
{
git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
}
build_linux()
{
make -C linux menuconfig
make -C linux "${JOBZ}" 
make -C linux INSTALL_MOD_PATH="${x}" modules_install
make -C linux install INSTALL_PATH="${x}/boot" 2>/dev/null
ln "${x}"/boot/vmlinuz* "${x}"/boot/vmlinuz
}

get_syslinux()
{
git clone git://git.kernel.org/pub/scm/boot/syslinux/syslinux.git
}
build_syslinux()
{
make -C syslinux "${JOBZ}"
}

get_busybox()
{
git clone git://busybox.net/busybox.git
}
build_busybox()
{
# compile busybox as a staticly linked executable
make -C busybox defconfig
sed -i 's|# CONFIG_STATIC is not set|CONFIG_STATIC=y|g' busybox/.config
make -C busybox "${JOBZ}"
make -C busybox CONFIG_PREFIX="${x}" install
}


create_disk()
{
dd if=/dev/zero of=binary.img bs=1M count=150
mkfs.ext4 -F binary.img
sudo mount binary.img "${x}"
mkdir -p "${x}"/dev "${x}"/proc "${x}"/boot "${x}"/etc "${x}"/root
}

create_configs()
{
cat > "${x}"/etc/inittab << EOF
null::sysinit:/bin/mount -t proc proc /proc
null::sysinit:/bin/mount -o remount,rw /
null::sysinit:/bin/mkdir -p /dev/pts
null::sysinit:/bin/mkdir -p /dev/shm
null::sysinit:/bin/mount -a
null::sysinit:/bin/hostname -F /etc/hostname
tty1::respawn:/sbin/getty -L tty1 115200 vt100
null::shutdown:/bin/umount -a -r
null::shutdown:/bin/swapoff -a
EOF
cat > "${x}"/etc/fstab << EOF
proc /proc proc defaults 0 0
EOF
cat > "${x}"/etc/hostname << EOF
simplelinux
EOF
cat > "${x}"/etc/passwd << EOF
root::0:0:root:/root:/bin/ash
EOF
cat > "${x}"/root/.bashrc << EOF
PS1="\[\033[35m\]\[\033[m\]\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]# "
EOF
cat > "${x}"/etc/profile << EOF
. /root/.bashrc
EOF

cat > ""${x}""/etc/group <<EOF
root:x:0: 
bin:x:1: 
sys:x:2: 
kmem:x:3: 
tty:x:4: 
tape:x:5: 
daemon:x:6: 
floppy:x:7: 
disk:x:8: 
lp:x:9: 
dialout:x:10: 
audio:x:11: 
video:x:12: 
utmp:x:13: 
usb:x:14: 
cdrom:x:15: 
EOF

}

use_extlinux()
{
sudo ./syslinux/extlinux/extlinux --install "${x}"
cat > "${x}"/extlinux.conf << EOF
default linux
label linux
kernel /boot/vmlinuz
append init=/sbin/init root=/dev/sda rw
EOF
}

[ -e syslinux ] || get_syslinux
build_syslinux

[ -e linux ] || get_linux
build_linux

[ -e busybox ] || get_busybox
build_busybox 

create_disk

create_configs

use_extlinux

sudo umount "${x}"
