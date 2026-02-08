#!/bin/bash
set -e

export TZ=Asia/Kolkata
export REPO_COLOR=never
export GIT_TERMINAL_PROMPT=0

sudo swapoff -a || true
sudo rm -f /swapfile || true
sudo sed -i '/swapfile/d' /etc/fstab || true

sudo apt update
sudo apt install -y git git-lfs curl zip unzip bc bison build-essential \
clang ccache flex g++-multilib gcc-multilib gnupg gperf imagemagick \
lib32readline-dev lib32z1-dev liblz4-tool libncurses-dev libssl-dev \
libxml2-utils lzop openjdk-17-jdk python-is-python3 rsync schedtool \
squashfs-tools xsltproc zlib1g-dev tmux rclone

git lfs install

export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_DIR=$HOME/.ccache
ccache -M 80G
ccache -z

mkdir -p ~/bin
curl -s https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod +x ~/bin/repo
export PATH=~/bin:$PATH

cd ~
mkdir -p infinityx
cd infinityx

yes | repo init --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16
SYNC_OK=0
repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j16 && SYNC_OK=1 || SYNC_OK=0
if [ "$SYNC_OK" -ne 1 ]; then
  repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j8 && SYNC_OK=1 || SYNC_OK=0
fi
if [ "$SYNC_OK" -ne 1 ]; then
  repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j4 && SYNC_OK=1 || SYNC_OK=0
fi
if [ "$SYNC_OK" -ne 1 ]; then
  repo sync -j1 --fail-fast
fi


[ -d device/oneplus/larry ] || git clone https://github.com/imCrest/android_device_oneplus_larry -b infinityx device/oneplus/larry
[ -d device/oneplus/sm6375-common ] || git clone https://github.com/imCrest/android_device_oneplus_sm6375-common -b lineage-23.2 device/oneplus/sm6375-common
[ -d vendor/oneplus/larry ] || git clone https://github.com/imCrest/proprietary_vendor_oneplus_larry -b lineage-23.2 vendor/oneplus/larry
[ -d vendor/oneplus/sm6375-common ] || git clone https://github.com/imCrest/proprietary_vendor_oneplus_sm6375-common -b lineage-23.2 vendor/oneplus/sm6375-common
[ -d kernel/oneplus/sm6375 ] || git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-23.2 kernel/oneplus/sm6375
[ -d hardware/oplus ] || git clone https://github.com/imCrest/android_hardware_oplus -b lineage-23.2 hardware/oplus

export SOONG_UI_THREADS=16
export NINJA_ARGS="-j32"

source build/envsetup.sh
lunch infinity_larry-userdebug

export WITH_GMS=false
export TARGET_SUPPORTS_GAPPS=false
export TARGET_SUPPORTS_GSUITE=false

mv device/oneplus/larry/infinity_larry.mk device/oneplus/larry/vanilla.txt
mka bacon -j32
mv out/target/product/larry out/target/product/vanilla

mv device/oneplus/larry/gapps.txt device/oneplus/larry/infinity_larry.mk

export WITH_GMS=true
export TARGET_SUPPORTS_GAPPS=true
export TARGET_SUPPORTS_GSUITE=true

mka bacon -j32
mv out/target/product/larry out/target/product/gapps

mv device/oneplus/larry/vanilla.txt device/oneplus/larry/infinity_larry.mk

PIXELDRAIN_KEY="f869dbb7-758e-4efa-9440-e1418b1c9916"

cd out/target/product/gapps
curl -T *.zip -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/

cd ../vanilla
curl -T *.zip -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/

ccache -s
