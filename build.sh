#!/bin/bash

# Install dependencies
sudo apt-get -y install libssl-dev

# Get latest Musl version from http://www.musl-libc.org/download.html
export musl_version=1.1.12
wget http://www.musl-libc.org/releases/musl-$musl_version.tar.gz
tar -xvf musl-$musl_version.tar.gz
cd musl-$musl_version
./configure --prefix=/usr/local  --disable-shared
make
sudo make install
cd ..

# Cleanup
rm -rf musl-$musl_version
rm musl-$musl_version.tar.gz

# Get latest OpenLDAP version from http://www.openldap.org/software/download/
export openldap_version=2.4.43
wget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-$openldap_version.tgz
tar -xvf openldap-$openldap_version.tgz
cd openldap-$openldap_version
CC="musl-gcc" LDFLAGS="-static" ./configure --prefix=/usr/local --disable-shared --disable-slapd
make depend
make

# Create an archive with the tools
cd clients; find tools/ -executable -type f | tar -cvzf ../../openldap-tools-$openldap_version-`uname -p`.tgz -T -; cd ../..

# Cleanup
rm -rf openldap-$openldap_version
rm openldap-$openldap_version.tgz
