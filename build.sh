#!/bin/bash

# Get latest Musl version from http://www.musl-libc.org/download.html
musl_version=1.1.12
# Get latest OpenSSL version from https://openssl.org/source/
openssl_version=1.0.2e
# Get latest OpenLDAP version from http://www.openldap.org/software/download/
openldap_version=2.4.43



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

# Build OpenSSL
wget https://openssl.org/source/openssl-$openssl_version.tar.gz
tar -xvf openssl-$openssl_version.tar.gz
cd openssl-$openssl_version
openssl_install=`pwd`/local
./config --prefix=$openssl_install no-shared
make
make install
cd ..

# Build Cyrus SASL
# Change Cyrus SASL version at your own risk (http://www.openldap.org/lists/openldap-technical/201202/msg00440.html)
cyrus_sasl_version=2.1.23
wget ftp://ftp.cyrusimap.org/cyrus-sasl/cyrus-sasl-$cyrus_sasl_version.tar.gz
tar -xvf cyrus-sasl-$cyrus_sasl_version.tar.gz
cd cyrus-sasl-$cyrus_sasl_version
cyrus_sasl_install=`pwd`/local
# Bug fix (http://www.linuxquestions.org/questions/linux-from-scratch-13/cyrus-sasl-2-1-23-fails-compiling-on-lfs-846940/)
sed -i.bak 's/#elif WITH_DES/#elif defined(WITH_DES)/' plugins/digestmd5.c
# Minimal SASL install
./configure --prefix=$cyrus_sasl_install --enable-static --disable-shared --disable-gssapi --disable-otp --disable-sample --without-des --without-gdbm
# Bug fix (https://lists.andrew.cmu.edu/pipermail/cyrus-sasl/2008-June/001413.html)
make || make
make install
cd ..

# Build OpenLDAP
wget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-$openldap_version.tgz
tar -xvf openldap-$openldap_version.tgz
cd openldap-$openldap_version
# LDFLAGS="-static" includes dependencies statically
# --with-tls=openssl forces building TLS
CC="$musl_install/bin/musl-gcc -I$openssl_install/include -L$openssl_install/lib" LDFLAGS="-static" ./configure --disable-shared --disable-slapd --with-tls=openssl
make depend
make

# Create an archive with the tools
cd clients; find tools/ -executable -type f | tar -cvzf ../../openldap-tools-$openldap_version-`uname -p`.tgz -T -; cd ../..

# Cleanup
rm -rf openssl-$openssl_version
rm openssl-$openssl_version.tar.gz
rm -rf musl-$musl_version
rm musl-$musl_version.tar.gz
rm -rf openldap-$openldap_version
rm openldap-$openldap_version.tgz
