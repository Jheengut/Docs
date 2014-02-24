#!/bin/sh

# (C) 2014 Documentation script, Statix, cgraf 
# Use `xorriso' with `isolinux' to make a "binary-hybrid.iso",

# Create a directory containing syslinux libraries.
rsync -a /usr/lib/syslinux ISO_root

# Create the configuration file "isolinux.cfg".
cat > ISO_root/syslinux/isolinux.cfg <<EOF
UI menu.c32
LABEL isolinuxtests
EOF

# Xorriso uses the library `libisofs', and can produce iso9660
# which have a rather conventional partition table if copied
# onto a USB.

# The option "-partition_offset 16" in `xorrisofs' helps
# fascilitate a peculiarity in GNU `parted' and is not required.
xorrisofs -r -J \
-o output.iso        \
-no-emul-boot        \
-boot-info-table     \
-boot-load-size 4    \
-c syslinux/boot.cat \
-b syslinux/isolinux.bin \
-partition_offset 16 \
-isohybrid-mbr ISO_root/syslinux/isohdpfx.bin \
ISO_root

# Put the .iso on a USB so it can be tested.
dd if=output.iso of=/dev/sdX

# Test boot the USB.
kvm /dev/sdX

# Make other partitions on the USB. (optional)
parted /dev/sdX mkpart primary 50% 75% -m -s
parted /dev/sdX mkpart primary 75% 100% -m -s
