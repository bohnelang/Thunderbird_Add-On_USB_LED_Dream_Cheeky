#!/bin/bash

# Later Frameworks than 10.7 throws compiler errors while not finding stdarg.h

export FRAMEWORK="10.6"

export CFLAGS="-O3 -pipe -fno-strict-aliasing -fomit-frame-pointer -ffunction-sections -fdata-sections -maccumulate-outgoing-args -mno-push-args -freorder-blocks-and-partition"

export LDFLAGS="\
 -isysroot/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk\
 -iframework/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk\
 -F/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/System/Library/Frameworks\
 -I/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/lib/gcc/i686-apple-darwin10/4.0.1/include/\
 -I/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/lib/gcc/i686-apple-darwin11/4.1.1/include/\
 -I/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/lib/gcc/i686-apple-darwin11/4.2.1/include/\
 -I/usr/i686-apple-darwin10/local/include\
 -I/usr/i686-apple-darwin10/include\
 -I/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/X11/include/\
 -I/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/include/\
 -I/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/include/libxml2\
 -L/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/lib\
 -L/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/lib/system\
 -L/usr/i686-apple-darwin10/local/lib\
 -L/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/lib/\
 -L/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/X11/lib/\
 -framework CoreFoundation\
 "

export CPPFLAGS="$LDFLAGS"


test "`which i686-apple-darwin10-gcc`" != "" && test -e /usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk && i686-apple-darwin10-gcc -m32 -std=gnu99  hello.c -o hello_x86.app  $CFLAGS   $LDFLAGS

test "`which i686-apple-darwin10-gcc`" != "" && test -e /usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk && i686-apple-darwin10-gcc -m64 -std=gnu99  hello.c -o hello_x86-64.app  $CFLAGS   $LDFLAGS

