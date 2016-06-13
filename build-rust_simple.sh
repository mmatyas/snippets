#! /bin/bash

set -o nounset
set -o errexit
set -o xtrace

git --version
if [[ ! -d rust ]]; then
    git clone --branch master git://github.com/rust-lang/rust.git
fi

cd rust
git pull
git submodule update

mkdir -p build
cd build

../configure \
    --disable-valgrind \
    --enable-llvm-static-stdcpp \
    --enable-rustbuild \
    --release-channel=nightly \
    --enable-dist-host-only \
    --build=x86_64-unknown-linux-gnu \
    --host=aarch64-unknown-linux-gnu
#    --host=aarch64-unknown-linux-gnu,arm-unknown-linux-gnueabihf,armv7-unknown-linux-gnueabihf

make clean
make -j`nproc`
make dist
