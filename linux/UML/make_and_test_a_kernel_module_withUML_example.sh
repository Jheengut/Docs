#!/bin/bash

# 2014 (C) Documentation script, Statix, cgraf 
# Simple guide to make, build, insert and test a kernel 
# module with user mode linux.

# get the linux kernel
git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

cd linux

# make a mini configuration file
cat > minimum.config << EOF 
CONFIG_BINFMT_ELF=y
CONFIG_HOSTFS=y
CONFIG_LBD=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_LOOP=y
CONFIG_STDERR_CONSOLE=y
CONFIG_UNIX98_PTYS=y
CONFIG_EXT2_FS=y
CONFIG_MODULES=y
EOF

mkdir -p  drivers/hello

# first makefile
cat >> drivers/Makefile << EOF
obj-y                           += hello/
EOF

# second makefile 
cat > drivers/hello/Makefile << EOF 
ifdef KERNELRELEASE

  obj-m := hello.o

else

clean:
       rm -f *.o *.ko *~ core .depend *.mod.c *.cmd 
endif
EOF

# make the actual module  hello.c
echo -E  \
'
#undef __KERNEL__
#define __KERNEL__
#undef MODULE
#define MODULE
#include <linux/module.h> 
#include <linux/kernel.h>  
#include <linux/init.h>     
static int __init hello_init(void)
{
    printk(KERN_INFO "Hello world!\n");
    return 0;  
}

static void __exit hello_cleanup(void)
{
    printk(KERN_INFO "Cleaning up module.\n");
}
module_init(hello_init);
module_exit(hello_cleanup);
MODULE_LICENSE("");

' > drivers/hello/hello.c

make ARCH=um allnoconfig KCONFIG_ALLCONFIG=minimum.config

make -j8 ARCH=um

# to run it :  

./vmlinux rootfstype=hostfs rw init=/bin/bash



