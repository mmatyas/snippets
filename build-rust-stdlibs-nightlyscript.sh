#! /bin/bash

set -o errexit
set -o nounset
set -o xtrace

date +%F\ %T

# Check if hash changed
rm -f rust-snapshot_date
wget https://raw.githubusercontent.com/servo/servo/master/rust-nightly-date -O rust-snapshot_date
if [[ ! $(diff rust-snapshot_date rust-snapshot_date-current) ]]; then exit 1; fi

time_start=$(date +%s)

# Get Rust hash of Servo
cd servo
git pull
./mach bootstrap-rust --force
rusthash=`./mach rustc -vV | awk 'NR==3' | cut -d' ' -f2`

# Checkout Rust
cd ../rust
git checkout master
git pull
git checkout $rusthash
git rev-parse HEAD

# Build
mkdir -p build && cd build
../configure \
--target=\
arm-unknown-linux-gnueabihf,aarch64-unknown-linux-gnu,\
arm-linux-androideabi,aarch64-linux-android,\
x86_64-unknown-linux-gnu \
--arm-linux-androideabi-ndk="$ANDROID_TOOLCHAIN_ARMHF" \
--aarch64-linux-android-ndk="$ANDROID_TOOLCHAIN_ARM64" \
--prefix=$(pwd)/install_$rusthash --disable-docs --enable-ccache
make -j4
make install

# Deploy
webpath=/var/www/html/servo/rust-cross
tar czf rust-armhf_aarch64_android-$rusthash.tgz -C install_$rusthash .
cp rust-armhf_aarch64_android-$rusthash.tgz $webpath

# Set as latest
rm $webpath/rust-armhf_aarch64_android-latest.tgz
ln -s rust-armhf_aarch64_android-$rustver.tgz $webpath/rust-armhf_aarch64_android-latest.tgz

# Remember hash
cd ../..
cp rust-snapshot_date rust-snapshot_date-current

time_end=$(date +%s)
runtime=$((time_end-time_start))
