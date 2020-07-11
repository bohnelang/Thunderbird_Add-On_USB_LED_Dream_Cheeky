#!/bin/bash

apt-get update 

apt-get install mingw-w64 
apt-get install mingw-w64-tools 

apt-get install lib32z1
apt-get install libudev-dev
apt-get install gcc-multilib

dpkg --add-architecture i386
apt-get update
apt-get install libc6:i386 
apt-get install libncurses5:i386 
apt-get install libstdc++6:i386 
apt-get install libudev-dev:i386

