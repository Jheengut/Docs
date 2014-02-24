#!/bin/sh

# Take the tails.iso apart and put it on a USB.
# The reason people usually want to do this is to change the
# boot parameters which are passed to the initramfs of the
# debian live style system. such as the option "persistence".


# Get a release of the Tails linux "tails.iso".
wget http://dl.amnesia.boum.org/tails/stable/tails-i386-0.22.1/tails-i386-0.22.1.iso

# Lets assume the USB we want to use is /dev/sdb 
# Make the partition label.
parted /dev/sdb mklabel msdos -m -s

# Partition the USB.
parted /dev/sdb mkpart primary 0% 100% -m -s

# Set boot flag.
parted /dev/sdb set 1 boot on 

# Format the newly made partition:
mkfs.ext4 -F /dev/sdb1 

# Mount the tails.iso so we can extract its contents.
mkdir mnt1  mnt2
mount -t iso9660 tails-i386-0.22.1.iso  mnt1

# Mount the first partition of the USB.  
mount /dev/sdb1 mnt2

# Copy the contents from the tail.iso to the USB. (takes a long time)
cp -r mnt1/live mnt2/
sync

# Copy in the syslinux libraries.
rsync -a /usr/lib/syslinux mnt2

# Install extlinux 
extlinux --install mnt2

# Make an "extlinux.conf" configuration file.
cat > mnt2/syslinux/extlinux.conf <<EOF
UI vesamenu.c32
DEFAULT linux
LABEL MyCustomTails
KERNEL /live/vmlinuz2
APPEND initrd=/live/initrd2.img  boot=live config
EOF

# Unmount the USB partition.
umount /dev/sdb1

# test boot (optional)
kvm -m 500 /dev/sdb

# (C) 2014 Documentation script, Statix, cgraf 
