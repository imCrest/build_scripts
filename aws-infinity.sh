#!/bin/bash
set -e

export TZ=Asia/Kolkata
export REPO_COLOR=never
export GIT_TERMINAL_PROMPT=0

sudo apt update && sudo apt upgrade -y

sudo apt install -y \
git git-lfs curl wget unzip zip \
bc bison build-essential \
clang ccache flex g++-multilib gcc-multilib \
gnupg gperf imagemagick \
lib32readline-dev lib32z1-dev \
liblz4-tool libncurses-dev libncurses6 \
libsdl1.2-dev libssl-dev libxml2 libxml2-utils \
lzop openjdk-17-jdk \
python-is-python3 python3 python3-pip \
rsync schedtool squashfs-tools xsltproc \
zlib1g-dev tmux

git lfs install

mkdir -p ~/bin
curl -s https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod +x ~/bin/repo
echo 'export PATH=~/bin:$PATH' >> ~/.bashrc
export PATH=~/bin:$PATH

repo --version

cd ~
mkdir -p infinityx
cd infinityx

yes | repo init -u https://github.com/ProjectInfinity-X/manifest -b 16 --git-lfs

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

git clone https://github.com/imCrest/android_device_oneplus_larry -b infinityx device/oneplus/larry
git clone https://github.com/imCrest/android_device_oneplus_sm6375-common -b lineage-23.1 device/oneplus/sm6375-common
git clone https://github.com/imCrest/proprietary_vendor_oneplus_larry -b lineage-23.1 vendor/oneplus/larry
git clone https://github.com/imCrest/proprietary_vendor_oneplus_sm6375-common -b lineage-23.1 vendor/oneplus/sm6375-common
git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-23.1 kernel/oneplus/sm6375
git clone https://github.com/imCrest/android_hardware_oplus -b lineage-23.1 hardware/oplus

source build/envsetup.sh
lunch infinity_larry-userdebug

make installclean
mka bacon -j$(nproc)

mv out/target/product/larry out/target/product/vanilla

mv device/oneplus/larry/gapps.txt device/oneplus/larry/infinity_larry.mk

make installclean
mka bacon -j$(nproc)

mv out/target/product/larry out/target/product/gapps

mv device/oneplus/larry/vanilla.txt device/oneplus/larry/infinity_larry.mk

echo "BUILD DONE"

