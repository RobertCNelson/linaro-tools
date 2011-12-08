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

#LINARO_VER="2011.11"
#QEMU_VER="0.15.91"

#LINARO_VER="2011.10"
#QEMU_VER="0.15.50"
#DISABLE_WERROR="--disable-werror"

#looking for: vexpress-a9
#LINARO_VER="2011.09"
#QEMU_VER="0.15.50"
#DISABLE_WERROR="--disable-werror"

#looking for: vexpress-a9
#LINARO_VER="2011.08"
#QEMU_VER="0.15.50"
#DISABLE_WERROR="--disable-werror"

#LINARO_VER="2011.07"
#SUB_VER="-0"
#QEMU_VER="0.14.50"
#DISABLE_WERROR="--disable-werror"

#LINARO_VER="2011.06"
#SUB_VER="-0"
#QEMU_VER="0.14.50"
#DISABLE_WERROR="--disable-werror"

LINARO_VER="2011.04"
SUB_VER="-1"
SUB_DATE="${SUB_VER}"
QEMU_VER="0.14.50"
DISABLE_WERROR="--disable-werror"

mkdir -p ${DIR}/dl/

echo ""
echo "Dependicies:"
echo "ubuntu/debian: sudo apt-get install libglib2.0-dev"
echo ""

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

cat > /tmp/qemu-arm << BINFMTS
package qemu-user-static
interpreter /usr/bin/qemu-arm-static
flags: OC
offset 0
magic \x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00
mask \xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff

BINFMTS

sudo cp /tmp/qemu-arm /usr/share/binfmts/qemu-arm

if [ -f /var/lib/binfmts/qemu-arm ]; then
 sudo update-binfmts --package qemu-user-static --remove qemu-arm /usr/bin/qemu-arm-static
fi

if [ -f /usr/share/binfmts/qemu-arm ]; then
 update-binfmts --import qemu-arm
fi

}

dl_qemu
extract_qemu
build_user_static
install_qemu_static
hack_install_arm_binfmts

