#! /bin/bash

set -e
set -x

git clone https://github.com/rust-lang/rust.git && cd rust
git checkout ${$1:-HEAD}
mkdir build && cd build

../configure \
    --prefix=$PWD/../installoc-$(git rev-parse --short HEAD) \
    --host=x86_64-unknown-linux-gnu --disable-llvm-assertions \
    --target=x86_64-unknown-linux-gnu,aarch64-unknown-linux-gnu

cd x86_64-unknown-linux-gnu
find . -type d -exec mkdir -p ../aarch64-unknown-linux-gnu/\{\} \;

cd llvm
../../../src/llvm/configure \
    --enable-target=x86,x86_64,arm,mips,aarch64 \
    --enable-optimized --disable-assertions --disable-docs \
    --enable-bindings=none --disable-terminfo --disable-zlib \
    --disable-libffi --with-python=/usr/bin/python2.7
make -j4

cd ../../aarch64-unknown-linux-gnu/llvm
../../../src/llvm/configure \
    --enable-target=x86,x86_64,arm,mips,aarch64 \
    --enable-optimized --disable-assertions --disable-docs \
    --enable-bindings=none --disable-terminfo --disable-zlib \
    --disable-libffi --with-python=/usr/bin/python2.7 \
    --build=x86_64-unknown-linux-gnu --host=aarch64-linux-gnu --target=aarch64-linux-gnu
make -j4

cd Release/bin
mv llvm-config llvm-config-aarch64
ln -s ../../BuildTools/Release/bin/llvm-config .
./llvm-config --cxxflags

cd ../../../..
chmod 0644 config.mk
grep 'CFG_LLVM_[BI]' config.mk | sed 's/x86_64\(.\)unknown.linux.gnu/aarch64\1unknown\1linux\1gnu/g' >> config.mk

cd ..
sed -i.bak 's/\([\t]*\)\(.*\$(MAKE).*\)/\1#\2/' mk/llvm.mk
sed -i.bak 's/^CRATES := .*/TARGET_CRATES += $(HOST_CRATES)\nCRATES := $(TARGET_CRATES)/' mk/crates.mk
sed -i.bak 's/\(.*call DEF_LLVM_VARS.*\)/\1\n$(eval $(call DEF_LLVM_VARS,aarch64-unknown-linux-gnu))/' mk/main.mk
sed -i.bak 's/foreach host,$(CFG_HOST)/foreach host,$(CFG_TARGET)/' mk/rustllvm.mk
sed -i.bak 's/.*target_arch = .*//' src/etc/mklldeps.py

cd build
./x86_64-unknown-linux-gnu/llvm/Release/bin/llvm-config --libs
./arm-unknown-linux-gnueabihf/llvm/Release/bin/llvm-config --libs

sed -i.bak 's/CFG_LLVM_LINKAGE_FILE/CFG_LLVM_LINKAGE_FILE_FIXED/g'  ../src/librustc_llvm/lib.rs
export CFG_LLVM_LINKAGE_FILE_FIXED=$PWD/x86_64-unknown-linux-gnu/rt/llvmdeps.rs
make -j4

LD_LIBRARY_PATH=$PWD/x86_64-unknown-linux-gnu/stage2/lib/rustlib/x86_64-unknown-linux-gnu/lib:$LD_LIBRARY_PATH \
    ./x86_64-unknown-linux-gnu/stage2/bin/rustc --cfg stage2 -O --cfg rtopt \
    -C linker=aarch64-linux-gnu-g++ -C ar=aarch64-linux-gnu-ar \
    --cfg debug -C prefer-dynamic --target=aarch64-unknown-linux-gnu \
    -o x86_64-unknown-linux-gnu/stage2/lib/rustlib/aarch64-unknown-linux-gnu/bin/rustc \
    --cfg rustc ../src/driver/driver.rs
LD_LIBRARY_PATH=$PWD/x86_64-unknown-linux-gnu/stage2/lib/rustlib/x86_64-unknown-linux-gnu/lib:$LD_LIBRARY_PATH \
    ./x86_64-unknown-linux-gnu/stage2/bin/rustc --cfg stage2 -O --cfg rtopt \
    -C linker=aarch64-linux-gnu-g++ -C ar=aarch64-linux-gnu-ar \
    --cfg debug -C prefer-dynamic --target=aarch64-unknown-linux-gnu \
    -o x86_64-unknown-linux-gnu/stage2/lib/rustlib/aarch64-unknown-linux-gnu/bin/rustdoc \
    --cfg rustdoc ../src/driver/driver.rs

mkdir -p cross-dist/lib/rustlib/aarch64-unknown-linux-gnu
cd cross-dist
cp -R ../x86_64-unknown-linux-gnu/stage2/lib/rustlib/aarch64-unknown-linux-gnu/* lib/rustlib/aarch64-unknown-linux-gnu
mv lib/rustlib/aarch64-unknown-linux-gnu/bin .
cd lib
for i in rustlib/aarch64-unknown-linux-gnu/lib/*.so; do ln -s $i .; done
cd ..
tar cjf ../rust_aarch64-unknown-linux-gnu_$(git rev-parse --short HEAD).tbz2
