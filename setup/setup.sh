#!/bin/sh

# http://tuatini.me/building-tensorflow-as-a-standalone-project/

START_DIR="$PWD"

# install dependencies

sudo apt-get update

# for bazel
sudo apt-get install pkg-config zip g++ zlib1g-dev unzip default-jdk autoconf automake libtool curl

# for tensorflow

# for Python 2.7
sudo apt-get install python-pip python-numpy swig python-dev
sudo pip install wheel

# for Python 3.3+
sudo apt-get install python3-pip python3-numpy swig python3-dev
sudo pip3 install wheel

# install bazel
sudo apt-get install openjdk-8-jdk
echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
sudo apt-get update && sudo apt-get install bazel

# download tensorflow repo
git clone https://github.com/tensorflow/tensorflow.git

# run tensorflow/configure
cd tensorflow
./configure
cd "$START_DIR"

# build libtensorflow_cc.so
bazel build -c opt --verbose_failures //tensorflow:libtensorflow_cc.so

# compile protobuf dependencies
cd "$START_DIR"
mkdir /tmp/proto
tensorflow/tensorflow/contrib/makefile/download_dependencies.sh
cp -r tensorflow/tensorflow/contrib/makefile/downloads .
cd downloads/protobuf
./autogen
./configure --prefix=/tmp/proto/
make
make check
sudo make install
sudo ldconfig

# compile eigen dependencies
cd "$START_DIR"
cd downloads/eigen
mkdir build_dir
cd build_dir
cmake -DCMAKE_INSTALL_PREFIX=/tmp/eigen/ ../
make install
sudo ldconfig

# set up library and include directories
cd "$START_DIR"
mkdir -p lib
mkdir -p include/tensorflow/

# copy libraries
cp tensorflow/bazel-bin/tensorflow/libtensorflow_cc.so lib/
cp tensorflow/bazel-bin/tensorflow/libtensorflow_framework.so lib/
cp /tmp/proto/lib/libprotobuf.a lib/

# copy include files
cp -r tensorflow/bazel-genfiles/* include/
cp -r tensorflow/tensorflow/cc include/tensorflow/
cp -r tensorflow/tensorflow/core include/tensorflow/
cp -r tensorflow/third_party include/
cp -r /tmp/proto/include/* include/
cp -r /tmp/eigen/include/eigen3/* include/

mkdir -p include/

# cleanup
find lib/ -name "*.cc" -type f -delete
find include/ -name "*.cc" -type f -delete