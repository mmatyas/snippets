#! /bin/bash

set -o errexit
set -o nounset
set -o xtrace

date +%F\ %T

cd /home/mmatyas/Mozilla/rustcrossbuild
rm -f rust-snapshot-hash
wget https://raw.githubusercontent.com/servo/servo/master/rust-snapshot-hash

diff rust-snapshot-hash rust-snapshot-hash-current
if [[ $? -eq 0 ]]; then exit $?; fi

cd rust
git checkout master
git pull

rusthash=`git log --until="$(cat ../rust-snapshot-hash)" --oneline | head -n 1 | cut -d ' ' -f 1`
git checkout $rusthash

mkdir -p build && cd build
../configure --target=arm-unknown-linux-gnueabihf,aarch64-unknown-linux-gnu,x86_64-unknown-linux-gnu --prefix=$(pwd)/install_$rusthash --disable-docs --enable-ccache
make -j4
make install
tar czf rust-armhf-aarch64-$rusthash.tgz -C install_$rusthash .
cp rust-armhf-aarch64-$rusthash.tgz /var/www/html/servo/rust-cross/

cp rust-snapshot-hash ../rust-snapshot-hash-current
