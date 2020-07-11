#!/bin/bash

BUILDS=../builds

rm -f $BUILDS/blinky*

echo "Linux ..."
test "`which i686-linux-gnu-gcc`" != "" && i686-linux-gnu-gcc   blinky.c  -m32 -g -O  -o $BUILDS/blinky_x86  -ludev
test "`which x86_64-linux-gnu-gcc`" != "" && x86_64-linux-gnu-gcc blinky.c  -m64 -g -O  -o $BUILDS/blinky_x86-64  -ludev 
test "`which x86_64-linux-gnu-gcc`" != "" && x86_64-linux-gnu-gcc blinky.c  -m32 -g -O  -o $BUILDS/blinky_x86  -ludev 


echo "Windows ..."
test "`which i686-w64-mingw32-gcc`" != "" && i686-w64-mingw32-gcc    blinky.c -o $BUILDS/blinky_x86.exe -m32 -g -O3 -lsetupapi -mwindows
test "`which x86_64-w64-mingw32-gcc`" != "" && x86_64-w64-mingw32-gcc  blinky.c -o $BUILDS/blinky_x86-64.exe -m64 -g -O3 -lsetupapi -mwindows

echo "Mac ..."

export PATH="/usr/i686-apple-darwin10/bin/:$PATH"

export FRAMEWORK="10.6"

export CFLAGS="-O3 -pipe -fno-strict-aliasing -fomit-frame-pointer -ffunction-sections -fdata-sections -maccumulate-outgoing-args -mno-push-args -freorder-blocks-and-partition"

export LDFLAGS="\
 -isysroot/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk\
 -iframework/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk\
 -F/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/System/Library/Frameworks\
 -I/usr/lib/gcc/i686-apple-darwin10/4.2.1/include/\
 -I/usr/i686-apple-darwin10/include\
 -I/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/lib/gcc/i686-apple-darwin10/4.0.1/include/\
 -I/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/lib/gcc/i686-apple-darwin11/4.1.1/include/\
 -I/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/lib/gcc/i686-apple-darwin11/4.2.1/include/\
 -I/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/X11/include/\
 -I/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/include/\
 -I/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/include/libxml2\
 -L/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/lib\
 -L/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/lib/system\
 -L/usr/i686-apple-darwin10/local/lib\
 -L/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/lib/\
 -L/usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk/usr/X11/lib/\
 -framework CoreFoundation\
 -framework IOKit "

export CPPFLAGS="$LDFLAGS"


test "`which i686-apple-darwin10-gcc`" != "" && test -e /usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk && i686-apple-darwin10-gcc -m32 -std=gnu99  blinky.c -o $BUILDS/blinky_x86.app  $CFLAGS   $LDFLAGS   

test "`which i686-apple-darwin10-gcc`" != "" && test -e /usr/lib/apple/SDKs/MacOSX$FRAMEWORK.sdk && i686-apple-darwin10-gcc -m64 -std=gnu99  blinky.c -o $BUILDS/blinky_x86-64.app  $CFLAGS   $LDFLAGS   



###########
cp ../builds/blinky_* ../../Thunderbird-AddOn/content/bin/
