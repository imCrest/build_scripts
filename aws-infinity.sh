#!/bin/bash
set -e

export TZ=Asia/Kolkata
export REPO_COLOR=never
export GIT_TERMINAL_PROMPT=0

sudo swapoff -a || true
sudo rm -f /swapfile || true

export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
ccache -M 80G

sudo apt update
sudo apt install -y git git-lfs curl zip unzip bc bison build-essential \
clang ccache flex g++-multilib gcc-multilib gnupg gperf imagemagick \
lib32readline-dev lib32z1-dev liblz4-tool libncurses-dev libssl-dev \
libxml2-utils lzop openjdk-17-jdk python-is-python3 rsync schedtool \
squashfs-tools xsltproc zlib1g-dev tmux rclone

git lfs install

mkdir -p ~/bin
curl -s https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod +x ~/bin/repo
export PATH=~/bin:$PATH

cd ~
mkdir -p infinityx
cd infinityx

yes | repo init --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16
repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j24

git clone https://github.com/imCrest/android_device_oneplus_larry -b infinityx device/oneplus/larry || true
git clone https://github.com/imCrest/android_device_oneplus_sm6375-common -b lineage-23.2 device/oneplus/sm6375-common || true
git clone https://github.com/imCrest/proprietary_vendor_oneplus_larry -b lineage-23.2 vendor/oneplus/larry || true
git clone https://github.com/imCrest/proprietary_vendor_oneplus_sm6375-common -b lineage-23.2 vendor/oneplus/sm6375-common || true
git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-23.2 kernel/oneplus/sm6375 || true
git clone https://github.com/imCrest/android_hardware_oplus -b lineage-23.2 hardware/oplus || true

source build/envsetup.sh
lunch infinity_larry-userdebug

export WITH_GMS=false
export TARGET_SUPPORTS_GAPPS=false
export TARGET_SUPPORTS_GSUITE=false

make installclean
mka bacon -j24
mv out/target/product/larry out/target/product/vanilla

export WITH_GMS=true
export TARGET_SUPPORTS_GAPPS=true
export TARGET_SUPPORTS_GSUITE=true

make installclean
mka bacon -j24
mv out/target/product/larry out/target/product/gapps

PIXELDRAIN_KEY="f869dbb7-758e-4efa-9440-e1418b1c9916"

cd out/target/product/gapps
curl -T *.zip -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/

cd ../vanilla
curl -T *.zip -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/
