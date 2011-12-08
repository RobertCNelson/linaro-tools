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

DIR=$PWD
TEMPDIR=$(mktemp -d)

LINARO="qemu-linaro-0.15.91-2011.11"

mkdir -p ${DIR}/dl/

echo ""
echo "Dependicies:"
echo "ubuntu/debian: sudo apt-get install libglib2.0-dev"
echo ""

function dl_qemu {
 wget -c --directory-prefix=${DIR}/dl/ http://launchpad.net/qemu-linaro/trunk/2011.11/+download/qemu-linaro-0.15.91-2011.11.tar.gz
}

function extract_qemu {
 rm -rf ${DIR}/qemu-build/ || true
 mkdir -p ${DIR}/qemu-build/
 tar xf ${DIR}/dl/qemu-linaro-0.15.91-2011.11.tar.gz -C ${DIR}/qemu-build/
}

function build_qemu {
 cd ${DIR}/qemu-build/${LINARO}
 ./configure --prefix=/usr --target-list=arm-softmmu
 make
 cd ${DIR}
}

function install_qemu {
 cd ${DIR}/qemu-build/${LINARO}
 sudo make install
 cd ${DIR}
}

dl_qemu
extract_qemu
build_qemu

