#!/bin/sh

# Install FreeBSD in a `qemu' virtual machine.

# Get the sources
ftp ftp://ftp.freebsd.org/pub/FreeBSD/snapshots/i386/i386/9.1-STABLE/*

# Get a FreeBSD install image.
ftp ftp://ftp.freebsd.org/pub/FreeBSD/releases/i386/i386/ISO-IMAGES/9.1/FreeBSD-9.1-RELEASE-i386-memstick.img

# Create the root filesystem.
dd if=/dev/zero of=Root_filesystem bs=1M count=10000

# Install to the root filesystem you just created.
kvm -m 1000 FreeBSD-9.1-RELEASE-i386-memstick.img -hdd Root_filesystem

# Boot the newly made installation.
kvm -m 1000 Root_filesystem  -redir tcp:2223::22 & exit

# Add the user to the "wheel group
pw user  mod  username -G wheel

# Mount the installation with sshfs
mkdir ~/FBSD_mnt
sshfs -p 2223 johnnet@192.168.1.65 ~/FBSD_mnt
cp *.txz MANIFEST HOWTO  ~/FBSD_mnt

# ssh into the installation.
ssh -p 2223 johnnet@192.168.1.65

# Switch user to root.
su

# Csh colored login and ls
cat >> ~/.cshrc << EOF 
set prompt = "%{\033[32m%}%B<%n@%{\033[33m%}%m%{\033[33m%}>%b%{\033[0m%}%/ # "
alias ls ls -LGIla
[ -e /usr/local/bin/vim ] && alias vi vim
EOF

source ~/.cshrc


# adding keyboard and mouse support
cat >> /etc/rc.conf << EOF
moused_enable="YES"
hald_enable="YES"
dbus_enable="YES"
EOF

# Source installation
tar -C / -xzf src.txz
tar -C / -xzf kernel.txz

# Navigate to the kernel configuration directory.
cd /usr/src/sys/i386/conf

# Copy the generic configuration file.
cp GENERIC MY_KERNEL

# Set the ramdisk size in the kernel configuration file.
cat >> MY_KERNEL <<EOF
options  MD_ROOT_SIZE=5120
EOF
cat >> MY_KERNEL <<EOF
makeoptions    MFS_IMAGE=/root.fs
options        ROOTDEVNAME=\"ufs:md0\"
EOF

# Build the kernel.
cd /usr/src
make buildkernel KERNCONF=MY_KERNEL


# Find the location of the kernel ramdisk in bytes.
cd /usr/obj/usr/src/sys/
strings -td MY_KERNEL | grep "MFS Filesystem"

# Use the start and end bytes specified by `strings'. add 1 for tail.
head -c 4505376 kernel > kernel.new
cat rootfs.img >> kernel.new
tail -c +9748257 kernel >> kernel.new


# 
dd if=/dev/zero of=/root.fs bs=1M count=4
mdconfig -a -t vnode -f /root.fs
bsdlabel -w md0 auto
newfs -m 0 md0a
mdconfig -d -u 0


