#!/bin/bash

# This script could download and build sources for native repositories

cd $(dirname $0)

BUILD_DIR=$PWD/build
SRC_DIR=$BUILD_DIR/source
LIB_DIR=$BUILD_DIR/libs

mkdir -p $SRC_DIR

echo install gflags
cd $SRC_DIR
wget -nc 'https://github.com/gflags/gflags/archive/v2.1.2.zip'
tar -xf v2.1.2.zip
cd gflags-2.1.2
cmake -DCMAKE_INSTALL_PREFIX:PATH=$LIB_DIR/gflags
make install

export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:$LIB_DIR/gflags/include

echo install glog
cd $SRC_DIR
wget -nc 'https://github.com/google/glog/archive/v0.3.4.zip'
tar -xf v0.3.4.zip
cd glog-0.3.4
./configure --prefix=$LIB_DIR/glog
make install

echo install re2
cd $SRC_DIR
wget -nc 'https://github.com/google/re2/archive/2015-08-01.zip'
unzip 2015-08-01.zip
cd re2-2015-08-01
make prefix=$LIB_DIR/re2 install

echo install zlib
cd $SRC_DIR
wget -nc 'http://downloads.sourceforge.net/project/libpng/zlib/1.2.8/zlib-1.2.8.tar.xz'
tar -xf zlib-1.2.8.tar.xz
cd zlib-1.2.8
./configure --prefix=$LIB_DIR/zlib
make install

echo 'install boost'
cd $SRC_DIR
wget -nc 'http://downloads.sourceforge.net/project/boost/boost/1.58.0/boost_1_58_0.tar.gz'
tar -xf boost_1_58_0.tar.gz
cd boost_1_58_0
./bootstrap.sh
./b2 install --prefix=$LIB_DIR/boost

echo 'install openssl (needed for building thrift)'
cd $SRC_DIR
wget -nc 'http://www.openssl.org/source/openssl-1.0.2e.tar.gz'
tar -xf openssl-1.0.2e.tar.gz
cd openssl-1.0.2e
./config --shared --prefix=$LIB_DIR/openssl
make install

echo 'install thrift'
cd $SRC_DIR
wget -nc 'http://apache.mesi.com.ar/thrift/0.9.2/thrift-0.9.2.tar.gz'
tar -xf thrift-0.9.2.tar.gz
cd thrift-0.9.2
./configure --with-python=false --with-php=false --with-boost=$LIB_DIR/boost --with-openssl=$LIB_DIR/openssl --prefix=$LIB_DIR/thrift LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LIB_DIR/openssl/lib LDFLAGS=-L$LIB_DIR/openssl/lib CPPFLAGS=-I$LIB_DIR/openssl/include
make install

# You should only use it if there is no prebuilt
echo install clang
cd $SRC_DIR
wget -nc 'http://llvm.org/releases/3.7.0/llvm-3.7.0.src.tar.xz'
wget -nc 'http://llvm.org/releases/3.7.0/cfe-3.7.0.src.tar.xz'
wget -nc 'http://llvm.org/releases/3.7.1/compiler-rt-3.7.1.src.tar.xz'
wget -nc 'http://llvm.org/releases/3.7.0/libcxx-3.7.0.src.tar.xz'
wget -nc 'http://llvm.org/releases/3.7.1/libcxxabi-3.7.1.src.tar.xz'

tar -xf llvm-3.7.0.src.tar.xz
tar -xf cfe-3.7.0.src.tar.xz
tar -xf libcxx-3.7.0.src.tar.xz
tar -xf compiler-rt-3.7.1.src.tar.xz
tar -xf libcxxabi-3.7.1.src.tar.xz

mv llvm-3.7.0.src llvm
mv cfe-3.7.0.src llvm/tools/clang
mv compiler-rt-3.7.1.src llvm/projects/compiler-rt
mv libcxx-3.7.0.src llvm/projects/libcxx
mv libcxxabi-3.7.1.src llvm/projects/libcxxabi

mkdir llvm-build
cd llvm-build
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$LIB_DIR/llvm ../llvm
make install