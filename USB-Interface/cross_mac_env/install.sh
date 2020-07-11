#!/bin/bash

sudo su - roo

set -e

# Set manualiy - test uname -m if you are not shure: x64_64 = amd64 and i686 = i383 
#arch=i386
arch=amd64

echo "Select $arch as arcitecture"


# Download

# deps
apt-get update 

apt-get install   xz-utils libssl1.0.0 libssl1.0-dev libxml2-dev libxml2  quilt ccache cdbs build-essential debhelper

echo "testing libssl0.9.8_0.9.8o-7ubuntu3.1_${arch}.deb"
if ! test -e libssl0.9.8_0.9.8o-7ubuntu3.1_${arch}.deb
then
	wget http://archive.ubuntu.com/ubuntu/pool/universe/o/openssl098/libssl0.9.8_0.9.8o-7ubuntu3.1_${arch}.deb
	dpkg -i libssl0.9.8_0.9.8o-7ubuntu3.1_${arch}.deb 
fi


# x86a
if ! test -e apple-x86-gcc_4.2.1~5646.1flosoft2_${arch}.deb
then
	wget -c http://ppa.launchpad.net/flosoft/cross-apple/ubuntu/pool/main/a/apple-x86-gcc/apple-x86-gcc_4.2.1~5646.1flosoft2_${arch}.deb
fi
if ! test -e apple-x86-odcctools_758.159-0flosoft11_${arch}.deb
then
	wget -c http://ppa.launchpad.net/flosoft/cross-apple/ubuntu/pool/main/a/apple-x86-odcctools/apple-x86-odcctools_758.159-0flosoft11_${arch}.deb
fi

# ppc
if ! test -e apple-ppc-gcc_4.2.1~5646.1flosoft2_${arch}.deb
then
	wget -c http://ppa.launchpad.net/flosoft/cross-apple/ubuntu/pool/main/a/apple-x86-gcc/apple-ppc-gcc_4.2.1~5646.1flosoft2_${arch}.deb
fi
if ! test -e apple-ppc-odcctools_758.159-0flosoft11_${arch}.deb
then
	wget -c http://ppa.launchpad.net/flosoft/cross-apple/ubuntu/pool/main/a/apple-x86-odcctools/apple-ppc-odcctools_758.159-0flosoft11_${arch}.deb
fi

# ccache
if ! test -e ccache-lipo_1.0-0flosoft3_${arch}.deb
then
	wget -c http://ppa.launchpad.net/flosoft/cross-apple/ubuntu/pool/main/c/ccache-lipo/ccache-lipo_1.0-0flosoft3_${arch}.deb
fi


# Install

# Binary utilities
dpkg -i apple-x86-odcctools_758.159-0flosoft11_${arch}.deb 
dpkg -i apple-ppc-odcctools_758.159-0flosoft11_${arch}.deb 
dpkg -i ccache-lipo_1.0-0flosoft3_${arch}.deb 

# Apple SDKs (not provided)
if ! test -e build
then
	mkdir build
fi

cd  build

#for I in 10.5 10.6 10.7 10.8 10.9 10.10 10.11 10.12 10.13 10.14 10.15 10.4u 10.3.9
for I in 10.6    
do
	echo "Build Maxox SDK ${I}"


	if test -e apple-uni-sdk-${I}_1_${arch}.deb
	then
		continue
	fi

	if ! test -e ${I}
	then
		mkdir ${I}
	fi

	cd ${I}
	


	if ! test -e debian 
	then
		mkdir debian
	fi

	cd debian 


	echo "apple-uni-sdk-${I} (1) any; urgency=medium

  * Dummy package 

 -- John Smith <john@smith>  Thu, 07 Apr 2011 16:55:42 +0200
 " > changelog 

	echo "7" > compat

	echo "Source: apple-uni-sdk-${I}
Section: devel
Priority: extra
Maintainer: John Smith <john@smith>
Build-Depends: cdbs, debhelper (>= 7.0.50~)
Standards-Version: 3.8.4

Package: apple-uni-sdk-${I}
Architecture: any
Replaces: apple-uni-sdk
Conflicts: apple-uni-sdk
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: MacOSX ${I} SDK for apple cross compiler
" > control 

	echo "#!/usr/bin/make -f

include /usr/share/cdbs/1/rules/debhelper.mk
include /usr/share/cdbs/1/class/makefile.mk

DEB_STRIP_EXCLUDE        := MacOSX${I}
DEB_MAKE_CLEAN_TARGET    := clean
DEB_MAKE_BUILD_TARGET    := all
DEB_MAKE_INSTALL_TARGET  := install DESTDIR=\$(CURDIR)/debian/apple-uni-sdk-${I}
"> rules
	chmod 755 rules

	cd ..
	


	echo ".PHONY: all install clean

PREFIX ?= /usr
SDKDIR ?= \$(PREFIX)/lib/apple/SDKs

all:

clean:

install:
	mkdir -p \$(DESTDIR)\$(SDKDIR)/Library/Frameworks
	cp -rv MacOSX${I}.sdk \$(DESTDIR)\$(SDKDIR)/MacOSX${I}.sdk
	if ! test -e \$(DESTDIR)\$(SDKDIR)/MacOSX${I}.sdk/Library/; then mkdir  \$(DESTDIR)\$(SDKDIR)/MacOSX${I}.sdk/Library; fi
	ln -fvs ../../Library/Frameworks \$(DESTDIR)\$(SDKDIR)/MacOSX${I}.sdk/Library/Frameworks
	"> Makefile 

	chmod 755 Makefile


	cd ..

	if ! test -e MacOSX${I}.sdk.tar.xz
	then
		if ! test -e MacOSX${I}.sdk.tar
		then
			wget --user-agent="Mozilla/5.0 (X11; U; Linux i686; de; rv:1.9b5) Gecko/2008050509 Firefox/3.0b5" https://github.com/phracker/MacOSX-SDKs/releases/download/10.15/MacOSX${I}.sdk.tar.xz
		fi
	fi
	
	if test -e MacOSX${I}.sdk.tar.xz
	then
		if ! test -e MacOSX${I}.sdk.tar
		then
			unxz MacOSX${I}.sdk.tar.xz
		fi
	fi
	tar -xf MacOSX${I}.sdk.tar
	cp -rf  MacOSX${I}.sdk ${I}
	rm -rf MacOSX${I}.sdk
	nice xz -e  MacOSX${I}.sdk.tar &

	cd ${I}
	dpkg-buildpackage -uc -b -tc
	rm -rf  ${I}/MacOSX${I}.sdk
	cd ..

	rm -r ${I}
	rm *.buildinfo		
	rm *.changes
	
	echo "Installing apple-uni-sdk-${I}.deb..."
	dpkg -i apple-uni-sdk-${I}_1_${arch}.deb

done

cd ..



echo "SDKs are:"
ls -l build/apple-uni-sdk-*.deb


# Toolchains (ppc, i386, x86_64)
dpkg -i apple-x86-gcc_4.2.1~5646.1flosoft2_${arch}.deb 
dpkg -i apple-ppc-gcc_4.2.1~5646.1flosoft2_${arch}.deb 

echo 
echo 
echo "Keep in mind - the compiler has a hard build link to this sdk !!! "
echo | i686-apple-darwin10-gcc -E -Wp,-v -

echo "Success!"
