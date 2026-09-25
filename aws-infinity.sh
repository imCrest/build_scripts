#!/bin/bash

yes | repo init --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 17 -g default,-mips,-darwin,-notdefault && \

repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all) && \
repo sync -j1 --fail-fast && \
rm -rf device/oneplus/larry device/oneplus/sm6375-common vendor/oneplus/larry vendor/oneplus/sm6375-common kernel/oneplus/sm6375 hardware/oplus && \
git clone https://github.com/imCrest/android_device_oneplus-larry -b lineage-24.0 device/oneplus/larry && \
git clone https://github.com/imCrest/android_device_oneplus_sm6375-common -b lineage-24.0 device/oneplus/sm6375-common && \
git clone https://github.com/imCrest/proprietary_vendor_oneplus_larry -b lineage-24.0 vendor/oneplus/larry && \
git clone https://github.com/imCrest/proprietary_vendor_oneplus_sm6375-common -b lineage-24.0 vendor/oneplus/sm6375-common && \
git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-24.0 kernel/oneplus/sm6375 && \
git clone https://github.com/imCrest/android_hardware_oplus -b lineage-24.0 hardware/oplus && \

export WITH_GMS=true && export TARGET_SUPPORTS_GAPPS=true && export TARGET_SUPPORTS_GSUITE=true && \
source build/envsetup.sh && lunch infinity_larry-userdebug && make installclean && mka bacon -j$(nproc) && \
mv out/target/product/larry out/target/product/gapps

PIXELDRAIN_KEY="5e3368e8-606b-4dcc-bdc3-12a03e50e78d"

upload_to_pd () {
    curl -s -T "$1" -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/ | sed -n 's/.*"id":"\([^"]*\)".*/\1/p'
}

DATE=$(date +'%d-%m-%Y')
cd out/target/product/gapps
ZIP_GAPPS=$(ls *.zip | head -n 1)
ROM_VERSION=$(cut -d'-' -f3 <<< "$ZIP_GAPPS")
[ -z "$ROM_VERSION" ] && ROM_VERSION="3.9"

TAG_NAME="ARB-$ROM_VERSION"
DISPLAY_VERSION="${TAG_NAME#ARB-}"

cd ../../../..

PD_GAPPS_ID=$(upload_to_pd "out/target/product/gapps/$ZIP_GAPPS")
PD_BOOT_ID=$(upload_to_pd "out/target/product/gapps/boot.img")
PD_VBOOT_ID=$(upload_to_pd "out/target/product/gapps/vendor_boot.img")
PD_DTBO_ID=$(upload_to_pd "out/target/product/gapps/dtbo.img")

PD_GAPPS_LINK="https://pixeldrain.com/u/$PD_GAPPS_ID"
PD_BOOT_LINK="https://pixeldrain.com/u/$PD_BOOT_ID"
PD_VBOOT_LINK="https://pixeldrain.com/u/$PD_VBOOT_ID"
PD_DTBO_LINK="https://pixeldrain.com/u/$PD_DTBO_ID"

TELEGRAM_TOKEN="8172049270:AAGCCwse_qhY34zhm4vSKd6LNNoyTy-YFpY"
CHAT_ID="7911062735"

IMAGE_URL="https://raw.githubusercontent.com/imCrest/Infinityx-Release/main/Banner/banner.png"

MESSAGE="<b>Project Infinity X (Unofficial) | Android 16 (QPR-2)</b>
<b>Updated: $DATE</b>

<b>Maintainer</b> ~ <a href=\"tg://openmessage?user_id=7911062735\">SUJΛL</a>

<a href=\"https://github.com/imCrest/Infinityx-Release?tab=readme-ov-file\">This build is Arb, ask in community before flashing</a>

Gapps > <a href=\"$PD_GAPPS_LINK\">DOWNLOAD</a>

${DISPLAY_VERSION}V Changelogs - <a href=\"https://t.me/ProjectInfinityX/1847\">HERE</a>
Rom Screenshot - <a href=\"https://t.me/ProjectInfinityX/1697?single\">HERE</a>
Flashing Steps - <a href=\"https://youtu.be/vs2y1MAVWO0?si=FLFk-Igi1Be01SVo\">HERE</a>

Notes:
<blockquote>1. This is ARB Build dirty flash required</blockquote>

<blockquote>2. Here (Gapps)  <a href=\"$PD_BOOT_LINK\">Boot.img</a>  <a href=\"$PD_VBOOT_LINK\">Vendor_boot.img</a>  <a href=\"$PD_DTBO_LINK\">dtbo.img</a></blockquote>

<blockquote>3. If you have any query related to the device then please ask in the community, Please Don't DM Me</blockquote>

If you want more updates in the future nd <a href=\"https://t.me/Sujxlsahu?text=I%20want%20to%20donate%20to%20you\">Donate</a> only if you feel I deserve it (Optional)

Enjoy.."

curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendPhoto" \
-d chat_id="$CHAT_ID" \
-d photo="$IMAGE_URL" \
-d parse_mode="HTML" \
-d caption="$MESSAGE" > /dev/null

if [ -n "$PD_GAPPS_ID" ]; then
    PD_MESSAGE="<b>Pixeldrain Mirrors:</b>
• <a href=\"$PD_GAPPS_LINK\">$ZIP_GAPPS</a>
• <a href=\"$PD_BOOT_LINK\">boot.img</a>
• <a href=\"$PD_VBOOT_LINK\">vendor_boot.img</a>
• <a href=\"$PD_DTBO_LINK\">dtbo.img</a>"

    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d parse_mode="HTML" \
    -d text="$PD_MESSAGE" \
    -d disable_web_page_preview="true" > /dev/null
fi
