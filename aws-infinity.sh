#!/bin/bash

yes | repo init --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 17 -g default,-mips,-darwin,-notdefault && \

repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all) && \
repo sync -j1 --fail-fast && \

git clone https://github.com/imCrest/android_device_oneplus-larry -b lineage-24.0 device/oneplus/larry && \
git clone https://github.com/LineageOS/android_device_oneplus_sm6375-common -b lineage-24.0 device/oneplus/sm6375-common && \
git clone https://github.com/TheMuppets/proprietary_vendor_oneplus_larry -b lineage-23.2 vendor/oneplus/larry && \
git clone https://github.com/TheMuppets/proprietary_vendor_oneplus_sm6375-common -b lineage-23.2 vendor/oneplus/sm6375-common && \
git clone https://github.com/LineageOS/android_kernel_oneplus_sm6375 -b lineage-24.0 kernel/oneplus/sm6375 && \
git clone https://github.com/LineageOS/android_hardware_oplus -b lineage-24.0 hardware/oplus && \

export WITH_GMS=true && export TARGET_SUPPORTS_GAPPS=true && export TARGET_SUPPORTS_GSUITE=true && \
source build/envsetup.sh && lunch infinity_larry-userdebug && make installclean && mka bacon -j$(nproc) && \
mv out/target/product/larry out/target/product/gapps

PIXELDRAIN_KEY="f869dbb7-758e-4efa-9440-e1418b1c9916"
export GITHUB_TOKEN=$MY_GH_TOKEN
GITHUB_REPO="imCrest/Infinityx-Release"

upload_to_pd () {
    curl -s -T "$1" -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/ | sed -n 's/.*"id":"\([^"]*\)".*/\1/p'
}

DATE=$(date +'%d-%m-%Y')
cd out/target/product/gapps
ZIP_GAPPS=$(ls *.zip | head -n 1)
ROM_VERSION=$(cut -d'-' -f3 <<< "$ZIP_GAPPS")
[ -z "$ROM_VERSION" ] && ROM_VERSION="3.9"

TAG_NAME="ARB-$ROM_VERSION"
COUNTER=1
while gh release view "$TAG_NAME" --repo "$GITHUB_REPO" >/dev/null 2>&1; do
    TAG_NAME="ARB-${ROM_VERSION}.${COUNTER}"
    COUNTER=$((COUNTER + 1))
done

cd ../../../..

PD_GAPPS_ID=$(upload_to_pd "out/target/product/gapps/$ZIP_GAPPS")
PD_BOOT_ID=$(upload_to_pd "out/target/product/gapps/boot.img")
PD_VBOOT_ID=$(upload_to_pd "out/target/product/gapps/vendor_boot.img")
PD_DTBO_ID=$(upload_to_pd "out/target/product/gapps/dtbo.img")

PD_GAPPS_LINK="https://pixeldrain.com/u/$PD_GAPPS_ID"
PD_BOOT_LINK="https://pixeldrain.com/u/$PD_BOOT_ID"
PD_VBOOT_LINK="https://pixeldrain.com/u/$PD_VBOOT_ID"
PD_DTBO_LINK="https://pixeldrain.com/u/$PD_DTBO_ID"

RELEASE_NOTES="Add QS Panel styles (HyperOS/OxygenOS/InfinityX Style)

Add statusbar icon packs, signal-wifi icon styles, battery icon styles and charging animations

Fixed MyAirtel app and DigiLocker app crash and fixed other tons of banking apps

Switch GameSpace implementation to AxionOS's gamespace

Allow changing system emoji styles to iOS or Samsung

Make lockscreen notifications appear over depth wallpaper

Add OmniJaws frontend inbuilt weather app

Fixed Firefox/browsers SystemUI crash on media playing when dynamic bar enabled

Fixed headsup dialer notification on incoming calls when dynamic bar enabled

Fixed dynamic bar download/other progress bars not updating on click to show expanded event & re-design dynamic bar lockscreen media popup view

Improve dynamic bar battery view on lockscreen along with actual charging info stats also allow to disable

Fixed dynamic bar messed up statusbar padding for some devices (eg. overlapping with statusbar or touching statusbar clock etc.)

Align dynamicbar lockscreen chip with keyguard indication margin

Suppress Dynamic Bar notifications when Danmaku notification is active

Added more screenrecorder options

Add QS Tiles animation styles

Enable statusbar burn-in protection for all devices by default

Restore stock android lockscreen bottom shortcut buttons along with size and paddings

Allow single tap behaviour instead of hold for lockscreen bottom shortcut buttons

Allow applying Monet colors to the lockscreen PIN and pattern screen (bouncer) view

Add feature to allow launching app in freeform window by swiping and holding it up in recents panel

Fixed smart pixels complete device freezing on use and improve logic

Make expanded volume panel ringer button shape completely circular

Add 2 new pulse styles along with toggle to configure bass haptics playback

Fixed QS tile inconsistent gradient colors with single tone tile style

Fixed camouflaging notifications footer buttons when alternate notification color enabled

Allow to show pure black/white qs notifications when alternate notification color disabled

Make statusbar display on lockscreen when media album art in use

Force disable all annoying inconsistent qs tile squish effects

New customizations for sidebar

Allow hiding lockscreen clock

Make volume slider haptics toggle work on expanded volume style too

Make idle manager more consistent and aggressive

Add toggle to prevent apps from launching the "Get this app from Play" screen when not installed from Play Store

Live circle battery style colors based on events like low battery or charging

Improve animations performance and system fluidity

Improve QS Panel janks/lag scenarios with plenty of notifications

Disable unnecessary logging and overhead conditions impacting performance and leading to battery drains"

DISPLAY_VERSION="${TAG_NAME#ARB-}"

SF_USER="${SF_USER:-sujxl}"
SF_DEST="${SF_USER}@frs.sourceforge.net:/home/frs/project/larry-rom-archive/Infinity-X/${DATE}/GAPPS/"
rsync -avP -e "ssh -o StrictHostKeyChecking=accept-new" --rsync-path="mkdir -p /home/frs/project/larry-rom-archive/Infinity-X/${DATE}/GAPPS && rsync" \
  "out/target/product/gapps/$ZIP_GAPPS" \
  "out/target/product/gapps/boot.img" \
  "out/target/product/gapps/vendor_boot.img" \
  "out/target/product/gapps/dtbo.img" \
  "$SF_DEST"

SF_GAPPS_URL="https://downloads.sourceforge.net/project/larry-rom-archive/Infinity-X/${DATE}/GAPPS/${ZIP_GAPPS}"
SF_BOOT_URL="https://downloads.sourceforge.net/project/larry-rom-archive/Infinity-X/${DATE}/GAPPS/boot.img"
SF_VBOOT_URL="https://downloads.sourceforge.net/project/larry-rom-archive/Infinity-X/${DATE}/GAPPS/vendor_boot.img"
SF_DTBO_URL="https://downloads.sourceforge.net/project/larry-rom-archive/Infinity-X/${DATE}/GAPPS/dtbo.img"

ZIP_SIZE=$(stat -c%s "out/target/product/gapps/$ZIP_GAPPS")
ZIP_MD5=$(md5sum "out/target/product/gapps/$ZIP_GAPPS" | cut -d" " -f1)
ZIP_TIMESTAMP=$(grep -m1 "ro.build.date.utc=" out/target/product/gapps/system/build.prop 2>/dev/null | cut -d"=" -f2)
[ -z "$ZIP_TIMESTAMP" ] && ZIP_TIMESTAMP=$(date +%s)

if [ "$ZIP_SIZE" -lt 2147483648 ]; then
    gh release create "$TAG_NAME" \
      "out/target/product/gapps/boot.img" \
      "out/target/product/gapps/dtbo.img" \
      "out/target/product/gapps/vendor_boot.img" \
      "out/target/product/gapps/$ZIP_GAPPS" \
      --repo "$GITHUB_REPO" --title "Project Infinity X (ARB) $DISPLAY_VERSION" --notes "$RELEASE_NOTES"
    GH_STATUS=$?
else
    gh release create "$TAG_NAME" \
      "out/target/product/gapps/boot.img" \
      "out/target/product/gapps/dtbo.img" \
      "out/target/product/gapps/vendor_boot.img" \
      --repo "$GITHUB_REPO" --title "Project Infinity X (ARB) $DISPLAY_VERSION" --notes "$RELEASE_NOTES"
    GH_STATUS=$?
fi

rm -rf /tmp/Infinityx-Release
git clone "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" /tmp/Infinityx-Release
cat << EOF > /tmp/Infinityx-Release/larry.json
{
  "response": [
    {
      "filename": "$ZIP_GAPPS",
      "download": "$SF_GAPPS_URL",
      "timestamp": $ZIP_TIMESTAMP,
      "md5": "$ZIP_MD5",
      "size": $ZIP_SIZE,
      "version": "$ROM_VERSION"
    }
  ]
}
EOF
git -C /tmp/Infinityx-Release config user.name "imCrest"
git -C /tmp/Infinityx-Release config user.email "crest@infinity-x.org"
git -C /tmp/Infinityx-Release add larry.json
git -C /tmp/Infinityx-Release commit -m "Update larry.json: ${ROM_VERSION} (${DATE})"
git -C /tmp/Infinityx-Release push origin main
rm -rf /tmp/Infinityx-Release

FINAL_GAPPS_LINK="$SF_GAPPS_URL"
BOOT_LINK="$SF_BOOT_URL"
V_BOOT_LINK="$SF_VBOOT_URL"
DTBO_LINK="$SF_DTBO_URL" 

TELEGRAM_TOKEN="8172049270:AAGCCwse_qhY34zhm4vSKd6LNNoyTy-YFpY"
CHAT_ID="7911062735"
PREV_VER1=$(awk "BEGIN {printf \"%.1f\", $ROM_VERSION - 0.2}")
PREV_VER2=$(awk "BEGIN {printf \"%.1f\", $ROM_VERSION - 0.1}")

IMAGE_URL="https://raw.githubusercontent.com/imCrest/Infinityx-Release/main/banner.png"

MESSAGE="<b>Project Infinity X (Unofficial) | Android 16 (QPR-2)</b>
<b>Updated: $DATE</b>

<b>Maintainer</b> ~ <a href=\"tg://openmessage?user_id=7911062735\">SUJΛL</a>

<a href=\"https://github.com/imCrest/Infinityx-Release?tab=readme-ov-file\">This build is Arb, ask in community before flashing</a>

Gapps > <a href=\"$FINAL_GAPPS_LINK\">DOWNLOAD</a>

${DISPLAY_VERSION}V Changelogs - <a href=\"https://t.me/ProjectInfinityX/1847\">HERE</a>
Rom Screenshot - <a href=\"https://t.me/ProjectInfinityX/1697?single\">HERE</a>
Flashing Steps - <a href=\"https://youtu.be/vs2y1MAVWO0?si=FLFk-Igi1Be01SVo\">HERE</a>

Notes:
<blockquote>1. This is ARB Build dirty flash required</blockquote>

<blockquote>2. Here (Gapps)  <a href=\"$BOOT_LINK\">Boot.img</a>  <a href=\"$V_BOOT_LINK\">Vendor_boot.img</a>  <a href=\"$DTBO_LINK\">dtbo.img</a></blockquote>

<blockquote>3. If you have any query related to the device then please ask in the community, Please Don't DM Me</blockquote>

If you want more updates in the future nd <a href=\"https://t.me/Sujxlsahu?text=I%20want%20to%20donate%20to%20you\">Donate</a> only if you feel I deserve it (Optional)

Enjoy.."

curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendPhoto" \
-d chat_id="$CHAT_ID" \
-d photo="$IMAGE_URL" \
-d parse_mode="HTML" \
-d caption="$MESSAGE" > /dev/null

PD_MESSAGE="<b>Pixeldrain Mirrors (If GitHub fails):</b>
• <a href=\"$PD_GAPPS_LINK\">$ZIP_GAPPS</a>
• <a href=\"$PD_BOOT_LINK\">boot.img</a>
• <a href=\"$PD_VBOOT_LINK\">vendor_boot.img</a>
• <a href=\"$PD_DTBO_LINK\">dtbo.img</a>"

curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
-d chat_id="$CHAT_ID" \
-d parse_mode="HTML" \
-d text="$PD_MESSAGE" \
-d disable_web_page_preview="true" > /dev/null
