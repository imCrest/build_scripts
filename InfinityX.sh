#!/bin/bash
repo init --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16 -g default,-mips,-darwin,-notdefault && \
/opt/crave/resync.sh && \
git clone https://github.com/imCrest/android_device_oneplus_larry -b infinityx device/oneplus/larry && \
git clone https://github.com/imCrest/android_device_oneplus_sm6375-common -b lineage-23.2 device/oneplus/sm6375-common && \
git clone https://github.com/imCrest/proprietary_vendor_oneplus_larry -b lineage-23.2-arb vendor/oneplus/larry && \
git clone https://github.com/imCrest/proprietary_vendor_oneplus_sm6375-common -b lineage-23.2 vendor/oneplus/sm6375-common && \
git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-23.2 kernel/oneplus/sm6375 && \
git clone https://github.com/imCrest/android_hardware_oplus -b lineage-23.2 hardware/oplus && \

export WITH_GMS=true && \
export TARGET_SUPPORTS_GAPPS=true && \
export TARGET_SUPPORTS_GSUITE=true && \
source build/envsetup.sh && \
lunch infinity_larry-userdebug && \
make installclean && \
mka bacon -j$(nproc) && \
mv out/target/product/larry out/target/product/gapps

PIXELDRAIN_KEY="f869dbb7-758e-4efa-9440-e1418b1c9916"
TELEGRAM_TOKEN="8172049270:AAGg1I0ah8CNV0PwtNg9cTz6AidYQLR4WQw"
CHAT_ID="7911062735"

upload_and_get_link () {
    FILE=$1
    if [ ! -f "$FILE" ]; then
        echo "#"
        return 1
    fi
    RESPONSE=$(curl -s -T "$FILE" -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/)
    ID=$(echo "$RESPONSE" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')
    if [ -n "$ID" ]; then
        echo "https://pixeldrain.com/u/$ID"
    else
        echo "#"
    fi
}

if cd out/target/product/gapps; then
    ZIP_FILE=$(ls *.zip | head -n 1)
    ROM_VERSION=$(echo "$ZIP_FILE" | cut -d'-' -f3)
    if [ -z "$ROM_VERSION" ]; then ROM_VERSION="3.8"; fi
    
    PREV_VER1=$(awk "BEGIN {printf \"%.1f\", $ROM_VERSION - 0.2}")
    PREV_VER2=$(awk "BEGIN {printf \"%.1f\", $ROM_VERSION - 0.1}")

    ROM_GAPPS=$(upload_and_get_link *.zip)
    BOOT=$(upload_and_get_link boot.img)
    VENDOR_BOOT=$(upload_and_get_link vendor_boot.img)
    DTBO=$(upload_and_get_link dtbo.img)
    cd ../../../.. 
else
    exit 1
fi

DATE=$(date +'%d/%B/%Y')

MESSAGE="<b>Project Infinity X (Unofficial) | Android 16 (QPR-2)</b>
<b>Updated: $DATE</b>

<b>Maintainer</b> ~ <a href=\"tg://openmessage?user_id=7911062735\">SUJΛL</a>

<tg-spoiler><a href=\"https://t.me/OnePlusNordCE3Lite/125856\">Before Flashing Any Rom Read This Note First</a></tg-spoiler>

Gapps > <a href=\"$ROM_GAPPS\">DOWNLOAD</a>

${ROM_VERSION}V Changelogs - <a href=\"YOUR_CHANGELOG_LINK_HERE\">HERE</a>
Rom Screenshot - <a href=\"https://t.me/ProjectInfinityX/1697?single\">HERE</a>
Flashing Steps - <a href=\"https://youtu.be/vs2y1MAVWO0?si=FLFk-Igi1Be01SVo\">HERE</a>

Notes:
<blockquote>1. Dirty Flash will be fine if you using ${PREV_VER1} or ${PREV_VER2} Build</blockquote>

<blockquote>2. Here (Gapps)  <a href=\"$BOOT\">Boot.img</a>  <a href=\"$VENDOR_BOOT\">Vendor_boot.img</a>  <a href=\"$DTBO\">dtbo.img</a></blockquote>

<blockquote>3. If you have any query related to the device then please ask in the community, Please Don't DM Me</blockquote>

If you want more updates in the future nd <a href=\"https://t.me/Sujxlsahu?text=I%20want%20to%20donate%20to%20you\">Donate</a> only if you feel I deserve it (Optional)

Enjoy.."

curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
-d chat_id="$CHAT_ID" \
-d parse_mode="HTML" \
-d disable_web_page_preview="true" \
-d text="$MESSAGE" > /dev/null
