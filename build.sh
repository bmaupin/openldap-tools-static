#!/bin/bash

# Get latest Musl version from http://www.musl-libc.org/download.html
musl_version=1.1.12
# Get latest OpenLDAP version from http://www.openldap.org/software/download/
openldap_version=2.4.43



# Install dependencies
if ! dpkg -l libssl-dev &> /dev/null; then
    sudo apt-get -y install libssl-dev
fi

# Build musl
wget http://www.musl-libc.org/releases/musl-$musl_version.tar.gz
tar -xvf musl-$musl_version.tar.gz
cd musl-$musl_version
musl_install=`pwd`/local
# --disable-shared is necessary because for some reason otherwise the OpenLDAP tools have a dependency on libc.so
# --enable-wrapper=gcc builds the musl-gcc binary wrapper
./configure --prefix=$musl_install --disable-shared --enable-wrapper=gcc
make
make install
cd ..

# Build openldap
wget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-$openldap_version.tgz
tar -xvf openldap-$openldap_version.tgz
cd openldap-$
# LDFLAGS="-static" includes dependencies statically
# --with-tls=openssl forces building TLS
CC="$musl_install/bin/musl-gcc" LDFLAGS="-static" ./configure --disable-shared --disable-slapd --with-tls=openssl
make depend
make

# Create an archive with the tools
cd clients; find tools/ -executable -type f | tar -cvzf ../../openldap-tools-$openldap_version-`uname -p`.tgz -T -; cd ../..

# Cleanup
rm -rf musl-$musl_version
rm musl-$musl_version.tar.gz
rm -rf openldap-$openldap_version
rm openldap-$openldap_version.tgz
