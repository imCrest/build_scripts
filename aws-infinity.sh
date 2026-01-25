#!/bin/bash
set -e

export TZ=Asia/Kolkata
export REPO_COLOR=never
export GIT_TERMINAL_PROMPT=0

if ! swapon --show | grep -q "/swapfile"; then
  sudo swapoff -a || true
  sudo rm -f /swapfile
  sudo fallocate -l 32G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  grep -q "/swapfile" /etc/fstab || printf "/swapfile none swap sw 0 0\n" | sudo tee -a /etc/fstab
fi

sudo apt update && sudo apt upgrade -y

sudo apt install -y \
git git-lfs curl wget unzip zip \
bc bison build-essential clang ccache flex g++-multilib gcc-multilib \
gnupg gperf imagemagick \
lib32readline-dev lib32z1-dev liblz4-tool \
libncurses-dev libncurses6 libsdl1.2-dev libssl-dev \
libxml2 libxml2-utils lzop \
openjdk-17-jdk \
python-is-python3 python3 python3-pip \
rsync schedtool squashfs-tools xsltproc zlib1g-dev \
tmux rclone

git lfs install

export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
ccache -M 100G

mkdir -p ~/bin
curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo -o ~/bin/repo
chmod +x ~/bin/repo
export PATH=~/bin:$PATH

cd ~
mkdir -p infinityx
cd infinityx

if [ ! -d .repo ]; then
  yes | repo init -u https://github.com/ProjectInfinity-X/manifest -b 16 --git-lfs
fi

repo sync -c --force-sync --no-clone-bundle --optimized-fetch -j$(nproc)

[ -d device/oneplus/larry ] || git clone https://github.com/imCrest/android_device_oneplus_larry -b infinityx device/oneplus/larry
[ -d device/oneplus/sm6375-common ] || git clone https://github.com/imCrest/android_device_oneplus_sm6375-common -b lineage-23.1 device/oneplus/sm6375-common
[ -d vendor/oneplus/larry ] || git clone https://github.com/imCrest/proprietary_vendor_oneplus_larry -b lineage-23.1 vendor/oneplus/larry
[ -d vendor/oneplus/sm6375-common ] || git clone https://github.com/imCrest/proprietary_vendor_oneplus_sm6375-common -b lineage-23.1 vendor/oneplus/sm6375-common
[ -d kernel/oneplus/sm6375 ] || git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-23.1 kernel/oneplus/sm6375
[ -d hardware/oplus ] || git clone https://github.com/imCrest/android_hardware_oplus -b lineage-23.1 hardware/oplus

source build/envsetup.sh
lunch infinity_larry-userdebug

export TARGET_BOOT_ANIMATION_RES=1080
export INFINITY_MAINTAINER=SUJΛL
export INFINITY_BUILD_TYPE=UNOFFICIAL
export TARGET_SUPPORTS_BLUR=true
export TARGET_FACE_UNLOCK_SUPPORTED=true

export PRODUCT_PRODUCT_PROPERTIES+=" ro.product.marketname=OnePlus Nord CE 3 Lite"
export PRODUCT_PRODUCT_PROPERTIES+=" ro.infinity.soc=Snapdragon 695 5G"
export PRODUCT_PRODUCT_PROPERTIES+=" ro.infinity.battery=5000 mAh"
export PRODUCT_PRODUCT_PROPERTIES+=" ro.infinity.display=1080 x 2400, 120 Hz"
export PRODUCT_PRODUCT_PROPERTIES+=" ro.infinity.camera=108MP + 2MP + 2MP + 16MP"

export WITH_GMS=true
rm -rf out/target/product/larry
mka bacon -j$(nproc)
mv out/target/product/larry out/target/product/gapps

export WITH_GMS=false
rm -rf out/target/product/larry
mka bacon -j$(nproc)
mv out/target/product/larry out/target/product/vanilla

API_KEY="09f8b105-5e37-4351-8024-fe610f788355"
BASE="$HOME/infinityx/out/target/product"

upload() {
  [ -f "$1" ] && curl -T "$1" -u ":$API_KEY" https://pixeldrain.com/api/file/
}

for V in gapps vanilla; do
  D="$BASE/$V"
  upload "$D"/*.zip
  upload "$D/boot.img"
  upload "$D/vendor_boot.img"
  upload "$D/dtbo.img"
done
