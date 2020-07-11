#!/bin/bash

cd ./USB-Interface

sudo ./need_packages.sh

cd  ./cross_mac_env
rm -rf *.deb
rm -rf ./build/*

sudo ./install.sh > /tmp/rebuild1.txt

cd ../../USB-Interface/src
./runme_all.sh

cd ../../Thunderbird-AddOn
./build.sh

cd ..

ls -la





