#!/bin/sh

# Automatically install netbsd on a UFS 
# formatted binary hard disk image.


# Create the hard disk image.
dd if=/dev/zero of=binary.img bs=1m count=150

# Attach a memory device to the hard disk image.
vnconfig vnd0 binary.img

# Format the memory disk.  
newfs vnd0a

# Mount the memory device.
mount /dev/vnd0a /mnt 

# A piece of boot loader code is needed:
cp /usr/mdec/boot  /mnt

# Populate the memory device.
ftp http://ftp.netbsd.org/pub/NetBSD/NetBSD-6.0/i386/binary/sets/base.tgz 
ftp http://ftp.netbsd.org/pub/NetBSD/NetBSD-6.0/i386/binary/sets/etc.tgz 
ftp http://ftp.netbsd.org/pub/NetBSD/NetBSD-6.0/i386/binary/sets/kern-GENERIC.tgz
tar xzfp kern-GENERIC.tgz -C /mnt
tar xzfp base.tgz -C /mnt
tar xzfp etc.tgz -C /mnt 

# Adjust the rc.conf file.  
cat >> /mnt/etc/rc.conf <<EOF
rc_configured=YES
EOF
# Make an fstab configuration file.
cat > /mnt/etc/fstab <<EOF
/dev/wd0a / ffs rw 0 0
EOF

# Unmount the memory device.
umount /mnt

# Create the disklabel.
( echo W; echo Y; echo Q; ) | disklabel -i vnd0

# Install the boot loader code.
installboot -vf binary.img /usr/mdec/bootxx_ffsv1 

# Disattach the memory device
vnconfig -u vnd0



# (C) 2014 Documentation Script, Statix, cgraf

