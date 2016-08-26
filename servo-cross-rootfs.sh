#! /bin/bash

set -o nounset
set -o errexit
set -o xtrace

UBIVERSION=xenial
ROOTFSPATH=rootfs-xenial-x64
ALTUSER=mmatyas

# Base
debootstrap --arch=amd64 --keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg --verbose xenial $ROOTFSPATH
mount -o bind /dev $ROOTFSPATH/dev
mount -o bind /proc $ROOTFSPATH/proc
mount -o bind /sys $ROOTFSPATH/sys

chroot $ROOTFSPATH useradd -m $ALTUSER -s /bin/bash
chroot $ROOTFSPATH passwd $ALTUSER
chroot $ROOTFSPATH usermod -aG sudo $ALTUSER
chroot $ROOTFSPATH sed -i 's/main/main universe/' /etc/apt/sources.list
chroot $ROOTFSPATH apt update
chroot $ROOTFSPATH apt install -y \
    git curl freeglut3-dev autoconf \
    libfreetype6-dev libgl1-mesa-dri libglib2.0-dev xorg-dev \
    gperf g++ build-essential cmake virtualenv python-pip \
    libssl-dev libbz2-dev libosmesa6-dev libxmu6 libxmu-dev \
    libglu1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev libdbus-1-dev \
    g++-arm-linux-gnueabihf g++-aarch64-linux-gnu

# ARM, AArch64 libs
chroot $ROOTFSPATH /bin/bash -c "curl -L https://github.com/mmatyas/mmatyas.github.io/releases/download/arm-libs/armhf-$UBIVERSION-libs.tgz | tar xzf - -C /"
chroot $ROOTFSPATH /bin/bash -c "curl -L https://github.com/mmatyas/mmatyas.github.io/releases/download/arm-libs/arm64-$UBIVERSION-libs.tgz | tar xzf - -C /"

# Compilers with -unknown-
chroot $ROOTFSPATH su - $ALTUSER -c 'mkdir $HOME/bin'
chroot $ROOTFSPATH su - $ALTUSER -c 'for f in /usr/bin/arm-linux-*; do f2=$(basename $f); ln -s $f $HOME/bin/${f2/-linux/-unknown-linux}; done'
chroot $ROOTFSPATH su - $ALTUSER -c 'for f in /usr/bin/aarch64-linux-*; do f2=$(basename $f); ln -s $f $HOME/bin/${f2/-linux/-unknown-linux}; done'

# Servo
chroot $ROOTFSPATH su - $ALTUSER -c 'git clone https://github.com/servo/servo'
chroot $ROOTFSPATH su - $ALTUSER -c 'cd servo'
chroot $ROOTFSPATH su - $ALTUSER -c 'cd servo && PKG_CONFIG_ALLOW_CROSS=1 PKG_CONFIG_PATH=/usr/lib/arm-linux-gnueabihf/pkgconfig EXPAT_NO_PKG_CONFIG=1 FREETYPE2_NO_PKG_CONFIG=1 FONTCONFIG_NO_PKG_CONFIG=1 ./mach build --rel --target=arm-unknown-linux-gnueabihf'
chroot $ROOTFSPATH su - $ALTUSER -c 'cd servo && PKG_CONFIG_ALLOW_CROSS=1 PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig EXPAT_NO_PKG_CONFIG=1 FREETYPE2_NO_PKG_CONFIG=1 FONTCONFIG_NO_PKG_CONFIG=1 ./mach build --rel --target=aarch64-unknown-linux-gnu'
chroot $ROOTFSPATH su - $ALTUSER -c 'cd servo && ./mach build --rel'
