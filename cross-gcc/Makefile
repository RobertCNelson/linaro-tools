# Makefile that builds a cross compiler against an existing system.
#
# This version fetches the Maverick libc and headers and builds a
# compiler against that.  To build for a different system,
# replace the sysroot.stamp rule with one that installs the headers
# and libc for your target.
#
# Tested on Ubuntu Lucid and Natty.  It should work on any recent Linux
# distribution.  The pre-built sysroot is pulled from Debian packages
# using 'ar'.
#
# Copyright (c) 2010, 2011 Linaro
# Contributors:
#   Michael Hope - initial implementation
#

# Basics:

# Target machine triplet
TARGET ?= arm-linux-gnueabi

# Where to install resulting tarball. Does not have to be writable.
PREFIX ?= $(HOME)/opt/gcc-linaro-cross

# What languages to build
LANGUAGES = c,c++,lto

# Configure flags to pass to GCC.  Sets the default system that GCC
# builds for.  Note that the calling convention must be the same as
# the pre-built sysroot
GCCFLAGS = --with-mode=thumb --with-arch=armv7-a --with-tune=cortex-a9 --with-float=softfp --with-fpu=neon

# Sources:

# The binutils version to build
#BINUTILSURL = http://archive.ubuntu.com/ubuntu/pool/main/b/binutils/binutils_2.21.0.20110327.orig.tar.gz

#2012.01
BINUTILSURL = http://archive.ubuntu.com/ubuntu/pool/main/b/binutils/binutils_2.22.orig.tar.gz

# The Linaro GCC version to build.  Check out
# https://launchpad.net/gcc-linaro/+download for the latest link.
#GCCURL = http://launchpad.net/gcc-linaro/4.6/4.6-2011.09/+download/gcc-linaro-4.6-2011.09-1.tar.bz2

#2012.01
#GCCURL = http://launchpad.net/gcc-linaro/4.6/4.6-2012.01/+download/gcc-linaro-4.6-2012.01.tar.bz2

#Mar 12, 2012 update
#GCCURL = https://launchpad.net/gcc-linaro/4.6/4.6-2012.02/+download/gcc-linaro-4.6-2012.02.tar.bz2

#April 9th, 2012 update
GCCURL = https://launchpad.net/gcc-linaro/4.6/4.6-2012.03/+download/gcc-linaro-4.6-2012.03.tar.bz2

# Sysroot:
# Where to fetch the packages from
MIRROR = http://ports.ubuntu.com/

# Set the pre-built headers and libc to build against.
#LIBC6VER = 2.12.1-0ubuntu6
#Mar 12, 2012 update
LIBC6VER = 2.12.1-0ubuntu10.4

#2012.01
#LIBC6VER = 2.13-24ubuntu4

#LINUXVER = 2.6.35-1022.33
#Mar 12, 2012 update
LINUXVER = 2.6.35-1032.68

#2012.01
#LINUXVER = 3.0.0-15.26

#http://ports.ubuntu.com/pool/main/e/eglibc/
#http://ports.ubuntu.com/pool/main/l/linux/

LIBC6        = pool/main/e/eglibc/libc6_${LIBC6VER}_armel.deb
LIBC6DEV     = pool/main/e/eglibc/libc6-dev_${LIBC6VER}_armel.deb
LINUXLIBCDEV = pool/main/l/linux/linux-libc-dev_${LINUXVER}_armel.deb

# All of the packages that go into the sysroot
PACKAGES = $(LIBC6) $(LIBC6DEV) $(LINUXLIBCDEV)

# The rest should be fine...
CURDIR := $(shell pwd)
GCCSRC = downloads/$(notdir $(GCCURL))
BINUTILSSRC = downloads/$(notdir $(BINUTILSURL))

# Where the headers and libc will end up.  Check out the GCC
# --with-build-sysroot configure option
SYSROOT = $(PREFIX)/$(TARGET)
BUILDSYSROOT = $(CURDIR)/build/sysroot

# Turns gcc-linaro-4.5.2.tar.xz into gcc-linaro, 4.5.2
PRODUCT = $(shell echo $(notdir $(GCCURL)) | sed -r 's/^([a-z\-]+)-([0-9].+)\.tar.+/\1/')
VERSION = $(shell echo $(notdir $(GCCURL)) | sed -r 's/^([a-z\-]+)-([0-9].+)\.tar.+/\2/')

# Directory to put all stamp files
stamp = stamp/

# Tell curl to follow links
CURLFLAGS = -L

-include local.mk

all: gcc

# Install into the configured directory
install: gcc
	mkdir -p $(DESTDIR)$(PREFIX)
	tar cf - -C $(BUILDSYSROOT)$(PREFIX) . | tar xf - -C $(DESTDIR)$(PREFIX)

# Make the final binary tarball
tarball: gcc
	echo Install into $(PREFIX) > $(BUILDSYSROOT)$(PREFIX)/INSTALL
	tar caf $(PRODUCT)-cross-$(TARGET)-$(VERSION).tar.bz2 --numeric-owner -C $(dir $(BUILDSYSROOT)$(PREFIX)) .

$(stamp)init-dirs:
	install -d src $(stamp) build downloads
	touch -t 9001010000 $@

# Binutils
binutils: $(stamp)binutils-install

# Fetch the binutils tarball from the web
$(BINUTILSSRC): $(stamp)init-dirs
	curl $(CURLFLAGS) -o $@ $(BINUTILSURL)

# Extract
$(stamp)binutils-extract: $(BINUTILSSRC) $(stamp)init-dirs
	tar xaf $< -C src
	touch $@

# Configure
$(stamp)binutils-configure: $(stamp)binutils-extract
	install -d build/binutils
	cd build/binutils && ../../src/binutils*/configure \
	--prefix=$(PREFIX) \
	--target=$(TARGET) \
	--disable-nls \
	--disable-werror \
	--enable-lto \
	--enable-gold \
	--with-sysroot=$(SYSROOT) \
	--with-build-sysroot=$(BUILDSYSROOT)
	touch $@

# Build and install
$(stamp)binutils-install: $(stamp)binutils-configure
	$(MAKE) -C build/binutils
	$(MAKE) -C build/binutils install DESTDIR=$(BUILDSYSROOT)
	touch $@

# Fetch and extract the sysroot.  Unfortunately the packages include
# absolute links in sysroot/usr/lib.  Fix these up to point to the
# sysroot instead.
$(stamp)sysroot-extract: $(stamp)init-dirs
	cd downloads && curl $(CURLFLAGS) $(PACKAGES:%=-O $(MIRROR)%)
	install -d $(BUILDSYSROOT)$(SYSROOT)
	for i in downloads/*.deb; do \
		rm -f data.*; \
		(cd src && ar x ../$$i); \
		tar xaf src/data.tar.* -C $(BUILDSYSROOT)$(SYSROOT); \
	done
	for i in $(BUILDSYSROOT)$(SYSROOT)/usr/lib/*; do \
		if [ -L $$i ] && (readlink $$i | grep -q ^/); then \
			x=`readlink $$i`; rm $$i; ln -s $(BUILDSYSROOT)$(SYSROOT)$$x $$i; \
	        fi; \
	done	
	touch $@

# Build GCC
gcc: $(stamp)gcc-install

# Fetch
$(GCCSRC): $(stamp)init-dirs
	curl $(CURLFLAGS) -o $@ $(GCCURL)

# Extract
$(stamp)gcc-extract: $(GCCSRC) $(stamp)init-dirs
	tar xaf $< -C src
	touch $@

# Configure
$(stamp)gcc-configure: $(stamp)binutils-install $(stamp)sysroot-extract $(stamp)gcc-extract
	install -d build/gcc 
	export PATH=$(BUILDSYSROOT)$(PREFIX)/bin:$(PATH) && \
	cd build/gcc && ../../src/gcc-*/configure \
	--enable-languages=$(LANGUAGES) \
	--prefix=$(PREFIX) \
	--target=$(TARGET) \
	--with-sysroot=$(SYSROOT) \
	--with-build-sysroot=$(BUILDSYSROOT)$(SYSROOT) \
	$(GCCFLAGS)
	touch $@

# Build and install
$(stamp)gcc-install: $(stamp)gcc-configure
	export PATH=$(BUILDSYSROOT)$(PREFIX)/bin:$(PATH) && \
	$(MAKE) -C build/gcc && \
	$(MAKE) -C build/gcc install DESTDIR=$(BUILDSYSROOT)
	touch $@

# Remove all temporary files
clean:
	rm -rf $(stamp) build src

# Remove all temporary files
distclean: clean
	rm -rf downloads *.tar.bz2 *~
