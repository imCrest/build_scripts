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
  if ! grep -q "/swapfile" /etc/fstab; then
    printf "/swapfile none swap sw 0 0\n" | sudo tee -a /etc/fstab
  fi
fi

sudo apt update && sudo apt upgrade -y
sudo apt install -y git git-lfs curl wget unzip zip \
bc bison build-essential clang ccache flex g++-multilib gcc-multilib \
gnupg gperf imagemagick lib32readline-dev lib32z1-dev \
liblz4-tool libncurses-dev libncurses6 libsdl1.2-dev libssl-dev \
libxml2 libxml2-utils lzop openjdk-17-jdk python-is-python3 python3 python3-pip \
rsync schedtool squashfs-tools xsltproc zlib1g-dev tmux rclone

git lfs install

mkdir -p ~/bin
curl -s https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod +x ~/bin/repo
export PATH=~/bin:$PATH

cd ~
mkdir -p rising
cd rising

yes | repo init -u https://github.com/RisingOS-Revived/android -b sixteen --git-lfs

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

[ -d device/oneplus/larry ] || git clone https://github.com/imCrest/android_device_oneplus-larry -b lineage-23.0 device/oneplus/larry
[ -d device/oneplus/sm6375-common ] || git clone https://github.com/imCrest/android_device_oneplus_sm6375-common -b lineage-23.0 device/oneplus/sm6375-common
[ -d vendor/oneplus/larry ] || git clone https://github.com/imCrest/proprietary_vendor_oneplus_larry -b lineage-23.0 vendor/oneplus/larry
[ -d vendor/oneplus/sm6375-common ] || git clone https://github.com/imCrest/proprietary_vendor_oneplus_sm6375-common -b lineage-23.0 vendor/oneplus/sm6375-common
[ -d kernel/oneplus/sm6375 ] || git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-23.0 kernel/oneplus/sm6375
[ -d hardware/oplus ] || git clone https://github.com/LineageOS/android_hardware_oplus -b lineage-23.0 hardware/oplus

export RISING_MAINTAINER="SUJAL"
export RISING_CHIPSET="Snapdragon 695 5G"
export TARGET_ENABLE_BLUR=true
export PRODUCT_NO_CAMERA=false
export TARGET_PREBUILT_LAWNCHAIR_LAUNCHER=false
export WITH_GMS=true
export TARGET_SUPPORTS_GAPPS=true
export TARGET_SUPPORTS_GSUITE=true

source build/envsetup.sh
lunch lineage_larry-userdebug
make installclean
mka bacon -j16
mv out/target/product/larry out/target/product/gapps

export WITH_GMS=false
export TARGET_SUPPORTS_GAPPS=false
export TARGET_SUPPORTS_GSUITE=false

source build/envsetup.sh
lunch lineage_larry-userdebug
make installclean
mka bacon -j16
mv out/target/product/larry out/target/product/vanilla
cd ~

PIXELDRAIN_KEY="09f8b105-5e37-4351-8024-fe610f788355"

cd rising/out/target/product/gapps
GAPPS_ZIP=$(ls *GAPPS*.zip)
curl -T "$GAPPS_ZIP" -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/

cd ../vanilla
VANILLA_ZIP=$(ls *VANILLA*.zip)
curl -T "$VANILLA_ZIP" -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/
