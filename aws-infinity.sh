#!/bin/bash
set -e

export TZ=Asia/Kolkata
export REPO_COLOR=never
export GIT_TERMINAL_PROMPT=0

sudo swapoff -a || true
sudo rm -f /swapfile || true
sudo sed -i '/swapfile/d' /etc/fstab || true

sudo sysctl -w vm.dirty_ratio=10
sudo sysctl -w vm.dirty_background_ratio=5

sudo apt update
sudo apt install -y git git-lfs curl zip unzip bc bison build-essential clang ccache flex g++-multilib gcc-multilib gnupg gperf imagemagick lib32readline-dev lib32z1-dev liblz4-tool libncurses-dev libssl-dev libxml2-utils lzop openjdk-17-jdk python-is-python3 rsync schedtool squashfs-tools xsltproc zlib1g-dev tmux rclone

git lfs install

export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_DIR=$HOME/.ccache
export CCACHE_BASEDIR=$HOME/infinityx
export CCACHE_COMPRESS=1
export CCACHE_COMPRESSLEVEL=6
export CCACHE_SLOPPINESS=time_macros

ccache -M 150G
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
repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j24 && SYNC_OK=1 || SYNC_OK=0
if [ "$SYNC_OK" -ne 1 ]; then
  repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j16 && SYNC_OK=1 || SYNC_OK=0
fi
if [ "$SYNC_OK" -ne 1 ]; then
  repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j8 && SYNC_OK=1 || SYNC_OK=0
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

CORES=$(nproc --all)
export SOONG_UI_THREADS=$CORES
export NINJA_ARGS="-j$((CORES*2))"
export _JAVA_OPTIONS="-Xmx8g"

source build/envsetup.sh
lunch infinity_larry-userdebug

export WITH_GMS=false
export TARGET_SUPPORTS_GAPPS=false
export TARGET_SUPPORTS_GSUITE=false

mv device/oneplus/larry/infinity_larry.mk device/oneplus/larry/vanilla.txt
mka bacon -j$((CORES*2))
mv out/target/product/larry out/target/product/vanilla

mv device/oneplus/larry/gapps.txt device/oneplus/larry/infinity_larry.mk

export WITH_GMS=true
export TARGET_SUPPORTS_GAPPS=true
export TARGET_SUPPORTS_GSUITE=true

mka bacon -j$((CORES*2))
mv out/target/product/larry out/target/product/gapps

mv device/oneplus/larry/vanilla.txt device/oneplus/larry/infinity_larry.mk

PIXELDRAIN_KEY="f869dbb7-758e-4efa-9440-e1418b1c9916"
TELEGRAM_TOKEN="8172049270:AAGg1I0ah8CNV0PwtNg9cTz6AidYQLR4WQw"
CHAT_ID="7911062735"

upload_and_get_link () {
    FILE=$1
    if [ ! -f "$FILE" ]; then
        echo "#"
        return 0
    fi
    RESPONSE=$(curl -s -T "$FILE" -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/)
    ID=$(echo "$RESPONSE" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')
    if [ -n "$ID" ]; then
        echo "https://pixeldrain.com/u/$ID"
    else
        echo "#"
    fi
}

cd ~/infinityx
if cd out/target/product/gapps; then
    ROM_GAPPS=$(upload_and_get_link *.zip)
    BOOT=$(upload_and_get_link boot.img)
    VENDOR_BOOT=$(upload_and_get_link vendor_boot.img)
    DTBO=$(upload_and_get_link dtbo.img)
    cd ../../../.. 
fi

if cd out/target/product/vanilla; then
    ROM_VANILLA=$(upload_and_get_link *.zip)
    cd ../../../.. 
fi

DATE=$(date +'%d/%B/%Y')

MESSAGE="<b>Project Infinity X (Unofficial) | Android 16 (QPR-2)</b>
<b>Updated: $DATE</b>

<b>Maintainer</b> ~ <a href=\"tg://openmessage?user_id=7911062735\">SUJΛL</a>

<tg-spoiler><a href=\"https://t.me/OnePlusNordCE3Lite/125856\">Before Flashing Any Rom Read This Note First</a></tg-spoiler>

Gapps > <a href=\"$ROM_GAPPS\">DOWNLOAD</a>

Vanilla > <a href=\"$ROM_VANILLA\">DOWNLOAD</a>

3.8V Changelogs - <a href=\"YOUR_CHANGELOG_LINK_HERE\">HERE</a>
Rom Screenshot - <a href=\"https://t.me/ProjectInfinityX/1697?single\">HERE</a>
Flashing Steps - <a href=\"https://youtu.be/vs2y1MAVWO0?si=FLFk-Igi1Be01SVo\">HERE</a>

Notes:
<blockquote>1. Dirty Flash will be fine if you using 3.6 or 3.7 Build</blockquote>

<blockquote>2. Here (Gapps)  <a href=\"$BOOT\">Boot.img</a>  <a href=\"$VENDOR_BOOT\">Vendor_boot.img</a>  <a href=\"$DTBO\">dtbo.img</a></blockquote>

<blockquote>3. If you have any query related to the device then please ask in the community, Please Don't DM Me</blockquote>

If you want more updates in the future nd <a href=\"https://t.me/Sujxlsahu?text=I%20want%20to%20donate%20to%20you\">Donate</a> only if you feel I deserve it (Optional)

Enjoy.."

curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
-d chat_id="$CHAT_ID" \
-d parse_mode="HTML" \
-d disable_web_page_preview="true" \
-d text="$MESSAGE" > /dev/null

ccache -s
