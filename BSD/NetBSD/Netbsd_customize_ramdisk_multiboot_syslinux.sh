#!/bin/sh

# Get a netbsd installer kernel, modify its ramdisk, 
# and multiboot it with syslinux.

# Unfortunately some of these commands are for *BSD only


# You will need a few packages.
pkg_add rsync cdrtools

# Get a multiboot compliant netbsd kernel that will run in ram:
ftp http://ftp.netbsd.org/pub/NetBSD/NetBSD-6.0/i386/binary/kernel/netbsd-INSTALL.gz 

# Unarchive the kernel.
gunzip netbsd-INSTALL.gz

# Extract the ramdisk from the kernel.
mdsetimage -x netbsd-INSTALL ramdisk.fs

# Attach a memory device to the kernels' ramdisk.
vnconfig vnd0 ramdisk.fs

# Mount the memory device that you just attached to the kernels' ramdisk.
mount -t ufs /dev/vnd0a /mnt

# Populate, and or otherwise make your changes to the memory disk/ramdisk.  
rm -r /mnt/sysi*

# Unmount the memory device.
umount /mnt

# Dis-attach the memory device the ramdisk.
vnconfig -u vnd0

# Insert the newly modified ramdisk image back into the kernel.
mdsetimage netbsd-INSTALL ramdisk.fs

# Gunzip the kernel.
gzip -f -9 netbsd-INSTALL

# Grab a syslinux package from debian wheezy, we only need its libraries.
ftp http://ftp.us.debian.org/debian/pool/main/s/syslinux/syslinux-common_4.05+dfsg-6+deb7u1_all.deb
ar -x syslinux-common_4.05+dfsg-6+deb7u1_all.deb
tar -xzf data.tar.xz 

# Create a root directory for `mkisofs' and copy in the syslinux libraries.
rsync -a usr/lib/syslinux ISO_root/


# Copy the kernel we modified into the root directory for the ISO9660, renaming it.
cp netbsd-INSTALL.gz ISO_root/netbsd


# Make the cofiguration file "isolinux.cfg".
cat > ISO_root/syslinux/isolinux.cfg <<EOF
UI vesamenu.c32
LABEL NetBsdExperiments
KERNEL mboot.c32
APPEND /netbsd
EOF


# Use 'mkisofs' to create the final bootable image.
mkisofs \
-o output.iso     \
-no-emul-boot     \
-boot-info-table  \
-boot-load-size 4 \
-c syslinux/boot.cat     \
-b syslinux/isolinux.bin \
ISO_root


# Test the .iso. (optional)
qemu -m 500 -cdrom output.iso



# (C) 2014 Documentation script, Statix, cgraf 
