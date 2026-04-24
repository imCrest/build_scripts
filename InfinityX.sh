#!/bin/bash

rm -rf .repo/local_manifests out/target/product/larry device/oneplus/larry device/oneplus/sm6375-common vendor/oneplus/larry vendor/oneplus/sm6375-common kernel/oneplus/sm6375 hardware/oplus && \

repo init --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16 -g default,-mips,-darwin,-notdefault && \
/opt/crave/resync.sh && \
git clone https://github.com/imCrest/android_device_oneplus_larry -b infinityx device/oneplus/larry && \
git clone https://github.com/imCrest/android_device_oneplus_sm6375-common -b lineage-23.2 device/oneplus/sm6375-common && \
git clone https://github.com/imCrest/proprietary_vendor_oneplus_larry -b lineage-23.2 vendor/oneplus/larry && \
git clone https://github.com/imCrest/proprietary_vendor_oneplus_sm6375-common -b lineage-23.2 vendor/oneplus/sm6375-common && \
git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-23.2 kernel/oneplus/sm6375 && \
git clone https://github.com/imCrest/android_hardware_oplus -b lineage-23.2 hardware/oplus && \

export WITH_GMS=true && export TARGET_SUPPORTS_GAPPS=true && export TARGET_SUPPORTS_GSUITE=true && \
source build/envsetup.sh && lunch infinity_larry-userdebug && make installclean && mka bacon -j$(nproc) && \
mv out/target/product/larry out/target/product/gapps && \

export WITH_GMS=false && export TARGET_SUPPORTS_GAPPS=false && export TARGET_SUPPORTS_GSUITE=false && \
source build/envsetup.sh && lunch infinity_larry-userdebug && make installclean && mka bacon -j$(nproc) && \
mv out/target/product/larry out/target/product/vanilla

PIXELDRAIN_KEY="f869dbb7-758e-4efa-9440-e1418b1c9916"
export GITHUB_TOKEN=$MY_GH_TOKEN
GITHUB_REPO="imCrest/Infinityx-Release-NonArb"

upload_to_pd () {
    curl -s -T "$1" -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/ | sed -n 's/.*"id":"\([^"]*\)".*/\1/p'
}

DATE=$(date +'%d/%B/%Y')
cd out/target/product/gapps
ZIP_GAPPS=$(ls *.zip | head -n 1)
ROM_VERSION=$(echo "$ZIP_GAPPS" | cut -d'-' -f3)
[ -z "$ROM_VERSION" ] && ROM_VERSION="3.9"

TAG_NAME="$ROM_VERSION"
COUNTER=1
while gh release view "$TAG_NAME" --repo "$GITHUB_REPO" >/dev/null 2>&1; do
    TAG_NAME="${ROM_VERSION}.${COUNTER}"
    COUNTER=$((COUNTER + 1))
done

cd ../../../..

PD_GAPPS_ID=$(upload_to_pd "out/target/product/gapps/$ZIP_GAPPS")
PD_VANILLA_ID=$(upload_to_pd "out/target/product/vanilla/"*.zip)
PD_GAPPS_LINK="https://pixeldrain.com/u/$PD_GAPPS_ID"
PD_VANILLA_LINK="https://pixeldrain.com/u/$PD_VANILLA_ID"

RELEASE_NOTES="Suck my Cock"

gh release create "$TAG_NAME" \
  "out/target/product/gapps/$ZIP_GAPPS" \
  "out/target/product/vanilla/"*.zip \
  "out/target/product/gapps/boot.img" \
  "out/target/product/gapps/vendor_boot.img" \
  "out/target/product/gapps/dtbo.img" \
  --repo "$GITHUB_REPO" \
  --title "Project Infinity X | larry | Non-ARB | $TAG_NAME" \
  --notes "$RELEASE_NOTES"

GH_STATUS=$?

GH_RELEASE_PAGE="https://github.com/$GITHUB_REPO/releases/tag/$TAG_NAME"
BASE_GH_URL="https://github.com/$GITHUB_REPO/releases/download/$TAG_NAME"

if [ $GH_STATUS -eq 0 ]; then
    FINAL_GAPPS_LINK="$GH_RELEASE_PAGE"
    FINAL_VANILLA_LINK="$GH_RELEASE_PAGE"
    BOOT_LINK="${BASE_GH_URL}/boot.img"
    V_BOOT_LINK="${BASE_GH_URL}/vendor_boot.img"
    DTBO_LINK="${BASE_GH_URL}/dtbo.img"
else
    FINAL_GAPPS_LINK="$PD_GAPPS_LINK"
    FINAL_VANILLA_LINK="$PD_VANILLA_LINK"
    BOOT_LINK="$PD_GAPPS_LINK"
    V_BOOT_LINK="$PD_GAPPS_LINK"
    DTBO_LINK="$PD_GAPPS_LINK"
fi

TELEGRAM_TOKEN="8172049270:AAGg1I0ah8CNV0PwtNg9cTz6AidYQLR4WQw"
CHAT_ID="7911062735"
PREV_VER1=$(awk "BEGIN {printf \"%.1f\", $ROM_VERSION - 0.2}")
PREV_VER2=$(awk "BEGIN {printf \"%.1f\", $ROM_VERSION - 0.1}")

IMAGE_URL="https://raw.githubusercontent.com/imCrest/Infinityx-Release/main/Banner/banner.png"

MESSAGE="<b>Project Infinity X (Unofficial) | Non-ARB | Android 16 (QPR-2)</b>
<b>Updated: $DATE</b>

<b>Maintainer</b> ~ <a href=\"tg://openmessage?user_id=7911062735\">SUJΛL</a>

Gapps > <a href=\"$FINAL_GAPPS_LINK\">DOWNLOAD</a>

Vanilla > <a href=\"$FINAL_VANILLA_LINK\">DOWNLOAD</a>

${TAG_NAME}V Changelogs - paste your changelogs
Rom Screenshot - <a href=\"https://t.me/ProjectInfinityX/1697?single\">HERE</a>
Flashing Steps - <a href=\"https://youtu.be/vs2y1MAVWO0?si=FLFk-Igi1Be01SVo\">HERE</a>

Notes:
<blockquote>1. This is a Non-ARB Build.</blockquote>

<blockquote>2. Dirty Flash will be fine if you using ${PREV_VER1} or ${PREV_VER2} Build</blockquote>

<blockquote>3. Here (Gapps)  <a href=\"$BOOT_LINK\">Boot.img</a>  <a href=\"$V_BOOT_LINK\">Vendor_boot.img</a>  <a href=\"$DTBO_LINK\">dtbo.img</a></blockquote>

<blockquote>4. If you have any query related to the device then please ask in the community, Please Don't DM Me</blockquote>

If you want more updates in the future nd <a href=\"https://t.me/Sujxlsahu?text=I%20want%20to%20donate%20to%20you\">Donate</a> only if you feel I deserve it (Optional)

Enjoy.."

curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendPhoto" \
-d chat_id="$CHAT_ID" \
-d photo="$IMAGE_URL" \
-d parse_mode="HTML" \
-d caption="$MESSAGE" > /dev/null
