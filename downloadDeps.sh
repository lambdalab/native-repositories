#!/bin/bash

# This script could download and build sources for native repositories

# we need cmake higher than 2.8.2

# suse need ncurses-devel // libbz2-devel make awk unzip tar libevent-devel
# manual install cmake
# zypper ar http://download.opensuse.org/repositories/home:/nocheck:/gcc/SLE_11_SP4/ gcc48repo
# zypper ar http://download.opensuse.org/repositories/home:/rusjako/SLE_11_SP3/ ssl_new
# zypper install gcc48-c++ libopenssl1_0_0


cd $(dirname $0)

BUILD_DIR=$PWD/build
SRC_DIR=$BUILD_DIR/source
LIB_DIR=$BUILD_DIR/libs

mkdir -p $SRC_DIR

echo install gflags
cd $SRC_DIR
wget -nc --no-check-certificate 'https://github.com/gflags/gflags/archive/v2.1.2.zip'
unzip v2.1.2
cd gflags-2.1.2
cmake -DCMAKE_INSTALL_PREFIX:PATH=$LIB_DIR/gflags
make install

export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:$LIB_DIR/gflags/include

echo install glog
cd $SRC_DIR
wget -nc --no-check-certificate 'https://github.com/google/glog/archive/v0.3.4.zip'
unzip v0.3.4
cd glog-0.3.4
./configure --prefix=$LIB_DIR/glog
make install

echo install re2
cd $SRC_DIR
wget -nc --no-check-certificate 'https://github.com/google/re2/archive/2015-08-01.zip'
unzip 2015-08-01
cd re2-2015-08-01
make prefix=$LIB_DIR/re2 install

echo install zlib
cd $SRC_DIR
wget -nc --no-check-certificate 'http://downloads.sourceforge.net/project/libpng/zlib/1.2.8/zlib-1.2.8.tar.xz'
tar -xf zlib-1.2.8.tar.xz
cd zlib-1.2.8
./configure --prefix=$LIB_DIR/zlib
make install

echo 'install boost'
cd $SRC_DIR
wget -nc --no-check-certificate 'http://downloads.sourceforge.net/project/boost/boost/1.58.0/boost_1_58_0.tar.gz'
tar -xf boost_1_58_0.tar.gz
cd boost_1_58_0
./bootstrap.sh
./b2 install --prefix=$LIB_DIR/boost

echo 'install openssl (needed for building thrift)'
cd $SRC_DIR
wget -nc --no-check-certificate 'https://github.com/openssl/openssl/archive/OpenSSL_1_0_2e.zip'
unzip OpenSSL_1_0_2e
cd openssl-OpenSSL_1_0_2e
./config --shared --prefix=$LIB_DIR/openssl
make install

echo 'install thrift'
cd $SRC_DIR
wget -nc --no-check-certificate 'http://apache.mesi.com.ar/thrift/0.9.2/thrift-0.9.2.tar.gz'
tar -xf thrift-0.9.2.tar.gz
cd thrift-0.9.2
./configure --with-python=false --with-php=false --with-boost=$LIB_DIR/boost --with-openssl=$LIB_DIR/openssl --prefix=$LIB_DIR/thrift LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LIB_DIR/openssl/lib LDFLAGS=-L$LIB_DIR/openssl/lib CPPFLAGS=-I$LIB_DIR/openssl/include
make install

# You should only use it if there is no prebuilt
#echo install clang
#cd $SRC_DIR
#LLVM_VERSION=3.7.0
#wget -nc "http://llvm.org/releases/$LLVM_VERSION/llvm-$LLVM_VERSION.src.tar.xz"
#wget -nc "http://llvm.org/releases/$LLVM_VERSION/cfe-$LLVM_VERSION.src.tar.xz"
#wget -nc "http://llvm.org/releases/$LLVM_VERSION/compiler-rt-$LLVM_VERSION.src.tar.xz"
#wget -nc "http://llvm.org/releases/$LLVM_VERSION/libcxx-$LLVM_VERSION.src.tar.xz"
#wget -nc "http://llvm.org/releases/$LLVM_VERSION/libcxxabi-$LLVM_VERSION.src.tar.x"
#
#tar -xf llvm-$LLVM_VERSION.src.tar.xz
#tar -xf cfe-$LLVM_VERSION.src.tar.xz
#tar -xf libcxx-$LLVM_VERSION.src.tar.xz
#tar -xf compiler-rt-$LLVM_VERSION.src.tar.xz
#tar -xf libcxxabi-$LLVM_VERSION.src.tar.xz
#
#mv llvm-$LLVM_VERSION.src llvm
#mv cfe-$LLVM_VERSION.src llvm/tools/clang
#mv compiler-rt-$LLVM_VERSION.src llvm/projects/compiler-rt
#mv libcxx-$LLVM_VERSION.src llvm/projects/libcxx
#mv libcxxabi-$LLVM_VERSION.src llvm/projects/libcxxabi
#
#mkdir llvm-build
#cd llvm-build
#cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$LIB_DIR/llvm ../llvm
#make install