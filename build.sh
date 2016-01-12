#!/bin/bash

# Get latest Musl version from http://www.musl-libc.org/download.html
export MUSL_VERSION=1.1.12
wget http://www.musl-libc.org/releases/musl-$MUSL_VERSION.tar.gz
tar -xvf musl-$MUSL_VERSION.tar.gz
cd musl-$MUSL_VERSION
CFLAGS="-O2" ./configure --prefix=/usr/local --disable-shared
make
sudo make install
cd ..

# Cleanup
rm -rf musl-$MUSL_VERSION
rm musl-$MUSL_VERSION.tar.gz

# Install dependencies
sudo apt-get -y install libssl-dev

# Get latest OpenLDAP version from http://www.openldap.org/software/download/
export OPENLDAP_VERSION=2.4.43
wget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-$OPENLDAP_VERSION.tgz
tar -xvf openldap-$OPENLDAP_VERSION.tgz
cd openldap-$OPENLDAP_VERSION
CC="musl-gcc" LDFLAGS="-static" ./configure --prefix=/usr/local --disable-shared --disable-slapd
make depend
make

# Create an archive with the tools
cd clients; find tools/ -executable -type f | tar -cvzf ../../openldap-tools-$OPENLDAP_VERSION-`uname -p`.tgz -T -; cd ../..
# Cleanup
rm -rf openldap-$OPENLDAP_VERSION
rm openldap-$OPENLDAP_VERSION.tgz
