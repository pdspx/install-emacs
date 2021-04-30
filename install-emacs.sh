#!/usr/bin/env bash

DIR_NAME=emacsbuild
WORKING_DIR=/tmp/$DIR_NAME
RAMDISK_SIZE=768m
URL="https://github.com/emacs-mirror/emacs/archive/refs/heads/master.zip"

function standard {
    ./configure --with-cairo CFLAGS="-O2 -mtune=native -march=native -pipe"
    make -j`nproc`
}

function native_comp {
    ./configure --with-native-compilation CFLAGS="-O2 -mtune=native -march=native -pipe"
    make -j`nproc` NATIVE_FULL_AOT=1
}

# We need root privileges for ramdisk & installation
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

# Setup ramdisk
mkdir -p $WORKING_DIR
chmod 777 $WORKING_DIR
mount -t tmpfs -o size=$RAMDISK_SIZE $DIR_NAME $WORKING_DIR
pushd $WORKING_DIR

# Download archive and decompress
curl -o emacs.zip -L $URL
unzip -qo emacs.zip
cd emacs-master

# Configure & build
./autogen.sh

if [[ $1 == 'native' ]]; then
    native_comp
else
    standard
fi

# Uninstall existing installation
make uninstall

# Install
make install

# Cleanup ramdisk
popd
umount $WORKING_DIR
