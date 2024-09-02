#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    cd "${OUTDIR}/linux-stable"
    echo "*************DEEP CLEANING KERNEL BUILD TREE*************"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper # deep clean kernel build tree, removes any .configs etc
    
    echo "*************DEFCONFIG FOR QEMU VIRT (arm64 - aarch64-none-linux-gnu-)*************"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig #defconfig for QEMU VIRT

    echo "*************BUILDING TARGET KERNEL IMAGE (vmlinux)*************"
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all #build kernel

    # echo "*************BUILDING KERNEL MODULES*************"
    # make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules #build kernel modules if any

     echo "*************BUILDING DEVICETREE*************"
     make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs #build the devicetree

fi

echo "...Adding the Image in outdir..."
cp "$OUTDIR/linux-stable/arch/arm64/boot/Image" $OUTDIR      #copying generated Image to OUTDIR

echo "...Creating the staging directory for the root filesystem..."
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir -v "${OUTDIR}/rootfs"
cd "${OUTDIR}/rootfs"
mkdir -vp bin dev etc home lib lib64 proc sys sbin tmp usr var
mkdir -vp usr/bin usr/lib usr/sbin
mkdir -vp var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    echo "*************CONFIGURING BUSYBOX*************"
    make distclean  # clean busybox, e.g .configs
    make defconfig  # defconfig
    
else
    cd busybox
fi

# TODO: Make and install busybox
    echo "*************MAKING BUSYBOX*************"
    make -j 4 -v ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
    
    echo "*************INSTALLING  BUSYBOX*************"
    make CONFIG_PREFIX="$OUTDIR/rootfs" ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install




# TODO: Add library dependencies to rootfs
SYSROOT_DIR=`dirname $(whereis aarch64-none-linux-gnu-gcc | cut -d " " -f2)`
#SYSROOT=$(${CROSS_COMPILE}gcc --print-sysroot)
SYSROOT=${SYSROOT_DIR}/../aarch64-none-linux-gnu/libc
cd ${OUTDIR}/rootfs
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

echo "*************ADDING LIB/LIB64 DEPENDENCIES*************"


cp -afv ${SYSROOT}/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib
cp -af ${SYSROOT}/lib64/ld-2.33.so ${OUTDIR}/rootfs/lib64

cp -afv ${SYSROOT}/lib64/libm.so.6 ${OUTDIR}/rootfs/lib64
cp -af ${SYSROOT}/lib64/libm-2.33.so ${OUTDIR}/rootfs/lib64

cp -afv ${SYSROOT}/lib64/libresolv.so.2 ${OUTDIR}/rootfs/lib64
cp -af ${SYSROOT}/lib64/libresolv-2.33.so ${OUTDIR}/rootfs/lib64

cp -afv ${SYSROOT}/lib64/libc.so.6 ${OUTDIR}/rootfs/lib64
cp -af ${SYSROOT}/lib64/libc-2.33.so ${OUTDIR}/rootfs/lib64


# TODO: Make device nodes
echo "*************MAKING DEVICE NODES*************"
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3
sudo mknod -m 600 ${OUTDIR}/rootfs/dev/console c 5 1
echo "Done"

# TODO: Clean and build the writer utility
echo "*************CLEAN BUILD WRITER APP*************"
FINDERAPP_DIR=`find /* -name "finder-app" -print -quit`
cd ${FINDER_APP_DIR}
make clean
make CROSS_COMPILE=aarch64-none-linux-gnu-

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
echo "*************COPYING NECESSARY FILES TO ROOTFS*************"
cp writer ${OUTDIR}/rootfs/home
cp finder.sh ${OUTDIR}/rootfs/home
cp autorun-qemu.sh ${OUTDIR}/rootfs/home
cp finder-test.sh ${OUTDIR}/rootfs/home

cp -r conf/ ${OUTDIR}/rootfs/home
echo "copied"

# TODO: Chown the root directory
sudo chown -hR root:root ${OUTDIR}/rootfs

# TODO: Create initramfs.cpio.gz
echo "*************CREATING INTIRAMFS.CPIO.GZ*************"
cd "$OUTDIR/rootfs"
find . | cpio -H newc -o --owner root:root > ${OUTDIR}/initramfs.cpio
cd ..
gzip -f initramfs.cpio
echo "*************ALL DONE*************"