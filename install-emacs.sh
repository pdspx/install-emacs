#!/usr/bin/env bash

DIR_NAME=emacsbuild
WORKING_DIR=/tmp/$DIR_NAME
RAMDISK_SIZE=768m
STANDARD_URL="https://github.com/emacs-mirror/emacs/archive/refs/heads/master.zip"
NATIVE_COMP_URL="https://github.com/emacs-mirror/emacs/archive/refs/heads/feature/native-comp.zip"

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

if [[ $1 == 'native' ]]; then
    url=$NATIVE_COMP_URL
    folder_name=emacs-feature-native-comp
else
    url=$STANDARD_URL
    folder_name=emacs-master
fi

# Setup ramdisk
mkdir -p $WORKING_DIR
chmod 777 $WORKING_DIR
mount -t tmpfs -o size=$RAMDISK_SIZE $DIR_NAME $WORKING_DIR
pushd $WORKING_DIR

# Download archive and decompress
curl -o emacs.zip -L $url
unzip -qo emacs.zip
cd $folder_name

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
