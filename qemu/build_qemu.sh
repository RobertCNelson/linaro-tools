#!/bin/bash -e
#
# Copyright (c) 2011 Robert Nelson <robertcnelson@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

unset DISABLE_WERROR
unset SUB_VER
unset SUB_DATE

DIR=$PWD
TEMPDIR=$(mktemp -d)

#fixes:2011.11
#qemu: Unsupported syscall: 231
#qemu: Unsupported syscall: 228 (a lot more)

#LINARO_VER="2011.12"
#QEMU_VER="1.0"
#Setting up libgtk2.0-0 (2.24.10-0ubuntu6) ...
#qemu: uncaught target signal 11 (Segmentation fault) - core dumped
#Segmentation fault

LINARO_VER="2012.01"
QEMU_VER="1.0.50"
#Setting up libgtk2.0-0 (2.24.10-0ubuntu6) ...
#qemu: uncaught target signal 11 (Segmentation fault) - core dumped
#Segmentation fault

mkdir -p ${DIR}/dl/

function dl_qemu {
 wget -c --directory-prefix=${DIR}/dl/ http://launchpad.net/qemu-linaro/trunk/${LINARO_VER}${SUB_DATE}/+download/qemu-linaro-${QEMU_VER}-${LINARO_VER}${SUB_VER}.tar.gz
}

function extract_qemu {
 rm -rf ${DIR}/qemu-build/ || true
 mkdir -p ${DIR}/qemu-build/
 tar xf ${DIR}/dl/qemu-linaro-${QEMU_VER}-${LINARO_VER}${SUB_VER}.tar.gz -C ${DIR}/qemu-build/
}

function build_user_static {
 mkdir -p  ${DIR}/qemu-build/qemu-linaro-${QEMU_VER}-${LINARO_VER}${SUB_VER}/user-static-build
 cd ${DIR}/qemu-build/qemu-linaro-${QEMU_VER}-${LINARO_VER}${SUB_VER}/user-static-build
 ../configure --prefix=/usr --sysconfdir=/etc --interp-prefix=/etc/qemu-binfmt/%M --disable-blobs --disable-strip --disable-system --static --target-list=arm-linux-user
 make
 cd ${DIR}
}

function install_qemu_static {
 cd ${DIR}/qemu-build/qemu-linaro-${QEMU_VER}-${LINARO_VER}${SUB_VER}/user-static-build
 sudo make install
 if [ ! -f /usr/bin/qemu-arm-static ] ; then
  sudo ln -s /usr/bin/qemu-arm /usr/bin/qemu-arm-static
 fi
 cd ${DIR}
}

function hack_install_arm_binfmts {
 sudo cp ${DIR}/debian/binfmts/qemu-arm /usr/share/binfmts/qemu-arm

 if [ -f /var/lib/binfmts/qemu-arm ]; then
  sudo update-binfmts --package qemu-user-static --remove qemu-arm /usr/bin/qemu-arm-static
 fi

 if [ -f /usr/share/binfmts/qemu-arm ]; then
  sudo update-binfmts --import qemu-arm
 fi
}

dl_qemu
extract_qemu
build_user_static
install_qemu_static
hack_install_arm_binfmts

