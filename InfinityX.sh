#!/bin/bash

sudo apt-get install gh -y

TELEGRAM_TOKEN="8773669605:AAGUh0YE7QLeOIoNqBlJC_aFoUPBDoHAhBM"
CHAT_ID="7911062735"
PIXELDRAIN_KEY="f869dbb7-758e-4efa-9440-e1418b1c9916"
GITHUB_REPO="imCrest/Infinityx-Release-NonArb"

send_msg() {
    local text="$1"
    local response=$(curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        --data-urlencode "chat_id=$CHAT_ID" \
        --data-urlencode "text=$text" \
        --data-urlencode "parse_mode=HTML" \
        --data-urlencode "disable_web_page_preview=true")
    MSG_ID=$(echo "$response" | grep -o '"message_id":[0-9]*' | cut -d':' -f2)
}

edit_msg() {
    local text="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/editMessageText" \
        --data-urlencode "chat_id=$CHAT_ID" \
        --data-urlencode "message_id=$MSG_ID" \
        --data-urlencode "text=$text" \
        --data-urlencode "parse_mode=HTML" \
        --data-urlencode "disable_web_page_preview=true"
}

send_msg "<b>Project Infinity X Build Status</b>\n\nStage 1: Repository Sync... [IN PROGRESS]"

rm -rf .repo/local_manifests out/target/product/larry device/oneplus/larry device/oneplus/sm6375-common vendor/oneplus/larry vendor/oneplus/sm6375-common kernel/oneplus/sm6375 hardware/oplus && \
repo init --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16 -g default,-mips,-darwin,-notdefault && \
/opt/crave/resync.sh

edit_msg "<b>Project Infinity X Build Status</b>\n\nStage 1: Repository Sync [DONE]\nStage 2: Cloning Device Trees... [IN PROGRESS]"

git clone https://github.com/imCrest/android_device_oneplus_larry -b infinityx device/oneplus/larry && \
git clone https://github.com/imCrest/android_device_oneplus_sm6375-common -b lineage-23.2 device/oneplus/sm6375-common && \
git clone https://github.com/imCrest/proprietary_vendor_oneplus_larry -b lineage-23.2 vendor/oneplus/larry && \
git clone https://github.com/imCrest/proprietary_vendor_oneplus_sm6375-common -b lineage-23.2 vendor/oneplus/sm6375-common && \
git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-23.2 kernel/oneplus/sm6375 && \
git clone https://github.com/imCrest/android_hardware_oplus -b lineage-23.2 hardware/oplus

edit_msg "<b>Project Infinity X Build Status</b>\n\nStage 2: Cloning Device Trees [DONE]\nStage 3: Build Environment Setup... [IN PROGRESS]"

export WITH_GMS=true && export TARGET_SUPPORTS_GAPPS=true && export TARGET_SUPPORTS_GSUITE=true && \
source build/envsetup.sh && lunch infinity_larry-userdebug && make installclean

edit_msg "<b>Project Infinity X Build Status</b>\n\nStage 3: Build Environment Setup [DONE]\nStage 4: Compiling ROM (GApps)... [INITIALIZING]"

mka bacon > build.log 2>&1 &
BUILD_PID=$!

while kill -0 $BUILD_PID; do
    sleep 15
    if [ -f build.log ]; then
        PROGRESS=$(tail -n 50 build.log | grep -o "\[ *[0-9]*% [0-9]*/[0-9]*\]" | tail -n 1)
        if [ ! -z "$PROGRESS" ]; then
            PCT=$(echo "$PROGRESS" | grep -o "[0-9]*%" | tr -d '%')
            BAR=$(printf "%0.s=" $(seq 1 $((PCT / 5))))
            SPACE=$(printf "%0.s-" $(seq 1 $(((100 - PCT) / 5))))
            
            TEXT="<b>Project Infinity X Build Status</b>\n\nStage 4: Compiling ROM (GApps)...\n\n$PROGRESS\n[${BAR}${SPACE}] ${PCT}%"
            edit_msg "$TEXT"
        fi
    fi
done

wait $BUILD_PID
BUILD_STATUS=$?

tail -n 300 build.log > build_last_300.txt
curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument" \
    -F "chat_id=$CHAT_ID" \
    -F "document=@build_last_300.txt" \
    -F "caption=Last 300 lines of build log."

if [ $BUILD_STATUS -ne 0 ]; then
    edit_msg "<b>Project Infinity X Build Status</b>\n\nStatus: Build FAILED at Stage 4! Check the attached log file."
    exit 1
fi

edit_msg "<b>Project Infinity X Build Status</b>\n\nStage 4: Compiling ROM [DONE]\nStage 5: Organizing Files... [IN PROGRESS]"

mv out/target/product/larry out/target/product/gapps

cd out/target/product/gapps
ZIP_GAPPS=$(ls *.zip | head -n 1)
ROM_VERSION=$(echo "$ZIP_GAPPS" | cut -d'-' -f3)
[ -z "$ROM_VERSION" ] && ROM_VERSION="3.9"

edit_msg "<b>Project Infinity X Build Status</b>\n\nStage 5: Organizing Files [DONE]\nStage 6: Uploading to Pixeldrain... [INITIALIZING]"

curl -T "$ZIP_GAPPS" -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/ 2> upload.log | sed -n 's/.*"id":"\([^"]*\)".*/\1/p' > pd_id.txt &
UPLOAD_PID=$!

while kill -0 $UPLOAD_PID; do
    sleep 5
    if [ -f upload.log ]; then
        UP_PCT=$(tail -n 1 upload.log | awk '{print $3}' | grep -o '^[0-9]\+')
        if [[ -n "$UP_PCT" && "$UP_PCT" =~ ^[0-9]+$ ]]; then
            BAR=$(printf "%0.s=" $(seq 1 $((UP_PCT / 5))))
            SPACE=$(printf "%0.s-" $(seq 1 $(((100 - UP_PCT) / 5))))
            
            TEXT="<b>Project Infinity X Build Status</b>\n\nStage 6: Uploading ROM to Pixeldrain...\n\n[${BAR}${SPACE}] ${UP_PCT}%"
            edit_msg "$TEXT"
        fi
    fi
done

PD_GAPPS_ID=$(cat pd_id.txt)

edit_msg "<b>Project Infinity X Build Status</b>\n\nStage 6: Uploading Images to Pixeldrain for Fallback... [IN PROGRESS]"
BOOT_ID=$(curl -s -T "boot.img" -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/ | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')
VBOOT_ID=$(curl -s -T "vendor_boot.img" -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/ | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')
DTBO_ID=$(curl -s -T "dtbo.img" -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/ | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')

PD_GAPPS_LINK="https://pixeldrain.com/u/$PD_GAPPS_ID"
cd ../../../..

edit_msg "<b>Project Infinity X Build Status</b>\n\nStage 6: Uploading [DONE]\nStage 7: Creating GitHub Release... [IN PROGRESS]"

TAG_NAME="$ROM_VERSION-Non-ARB"
COUNTER=1
while gh release view "$TAG_NAME" --repo "$GITHUB_REPO"; do
    TAG_NAME="${ROM_VERSION}-Non-ARB.${COUNTER}"
    COUNTER=$((COUNTER + 1))
done

RELEASE_NOTES="- Add statusbar/lockscreen dynamic bar implementation (author: rmp22)
- Add App drawer customizations and tunings (author: shutter-cat, pbzinwindows, ChrisCatto)
- Add Toggle to launch notification apps in bubble or floating screen (author: shutter-cat)
- Add optional toggleable Classic style QS Panel along with tile shapes and ability to hide labels (author: neobuddy89)
- Allow switching to default Android 16 brightness slider style
- Add detailed Idle manager with advanced per-app control (author: Ghosuto)
- Add 11 more Lockscreen custom clock styles (author: IDontCare-05, spkal01, Ghosuto)
- Fix custom clock styles disappearing on tablets or landscape rotation
- Allow applying volume panel gradient customization to extended volume panel style
- Allow showing Volume percentage on extended and expanded volume panel style 
- Add toggle to kill Flash SMS messages (author: adithya2306)
- Simplify Always-on-Display charging checks (author: NurKeinNeid)
- Remove QS boost hints that lead to battery drain / heat
- Remove unnecessary scrolling boost hints that lead to battery drain / heat
- Add back lockscreen weather wind and humidity info from v3.7
- Remove ongoing media chip // Fixes systemui crash issues while media was playing with media chip enabled
- Add optional Glow effect in notch ring (author: hxreborn)
- Add music playback progress in cutout ring  (author: Ghosuto)
- Improve padding for search icon in app drawer search bar when google app disabled
- Add launcher wallpaper carousel (author: MrSluffy)
- Fix default fonts display for regular and headline in QS Panel
- Fix NPE in CallListener Gamespace (author: neobuddy89)
- Fix scrolling in recovery image when touch is rotated (author: AnierinBliss)
- Allow changing size of custom clock styles (author: Ghosuto)
- Fix PlanesLockGuard buffer lock leak in av (author: jsebechlebsky)
- Fix preferences in launcher3 icon pack fragment turning purple upon clicking (author: neobuddy89)
- Hide VmTerminal fragment if device doesn't support it (author: luk1337)
- Improvements on memory usage and battery backup"

GH_RELEASE_PAGE="https://github.com/$GITHUB_REPO/releases/tag/$TAG_NAME"

DATE=$(date +'%d/%B/%Y')
PREV_VER1=$(awk "BEGIN {printf \"%.1f\", $ROM_VERSION - 0.2}")
PREV_VER2=$(awk "BEGIN {printf \"%.1f\", $ROM_VERSION - 0.1}")
IMAGE_URL="https://raw.githubusercontent.com/imCrest/Infinityx-Release/main/Banner/banner.png"

MESSAGE="<b>Project Infinity X (Unofficial) | Non-ARB | Android 16 (QPR-2)</b>
<b>Updated: $DATE</b>

<b>Maintainer</b> ~ <a href=\"tg://openmessage?user_id=7911062735\">SUJΛL</a>

Gapps > <a href=\"$GH_RELEASE_PAGE\">DOWNLOAD</a>

${TAG_NAME}V Changelogs - <a href=\"$GH_RELEASE_PAGE\">View Here</a>
Rom Screenshot - <a href=\"https://t.me/ProjectInfinityX/1697?single\">HERE</a>
Flashing Steps - <a href=\"https://youtu.be/vs2y1MAVWO0?si=FLFk-Igi1Be01SVo\">HERE</a>

Notes:
<blockquote>1. This is a Non-ARB Build.</blockquote>
<blockquote>2. Dirty Flash will be fine if you using ${PREV_VER1} or ${PREV_VER2} Build</blockquote>
<blockquote>3. Here (Gapps) files are included in the release page.</blockquote>
<blockquote>4. If you have any query related to the device then please ask in the community, Please Don't DM Me</blockquote>

If you want more updates in the future nd <a href=\"https://t.me/Sujxlsahu?text=I%20want%20to%20donate%20to%20you\">Donate</a> only if you feel I deserve it (Optional)

Enjoy.."

gh release create "$TAG_NAME" \
  "out/target/product/gapps/$ZIP_GAPPS" \
  "out/target/product/gapps/boot.img" \
  "out/target/product/gapps/vendor_boot.img" \
  "out/target/product/gapps/dtbo.img" \
  --repo "$GITHUB_REPO" \
  --title "Project Infinity X | larry | Non-ARB | $TAG_NAME" \
  --notes "$RELEASE_NOTES"

GH_STATUS=$?

if [ $GH_STATUS -eq 0 ]; then
    edit_msg "<b>Project Infinity X Build Status</b>\n\nStage 7: GitHub Release [DONE]\n\nStatus: All 7 Stages Completed Successfully!\nRelease Tag: $TAG_NAME"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendPhoto" -d chat_id="$CHAT_ID" -d photo="$IMAGE_URL" -d parse_mode="HTML" -d caption="$MESSAGE"
else
    edit_msg "<b>Project Infinity X Build Status</b>\n\nStage 7: GitHub Release [FAILED]\nGenerating Codespace Script..."
    
    ENCODED_MESSAGE=$(echo "$MESSAGE" | sed 's/"/\\"/g' | sed "s/'/\\'/g")
    
    CS_SCRIPT="#!/bin/bash
wget -q --show-progress https://pixeldrain.com/api/file/$PD_GAPPS_ID -O $ZIP_GAPPS
wget -q --show-progress https://pixeldrain.com/api/file/$BOOT_ID -O boot.img
wget -q --show-progress https://pixeldrain.com/api/file/$VBOOT_ID -O vendor_boot.img
wget -q --show-progress https://pixeldrain.com/api/file/$DTBO_ID -O dtbo.img

RELEASE_NOTES=\"- Add statusbar/lockscreen dynamic bar implementation (author: rmp22)
- Add App drawer customizations and tunings (author: shutter-cat, pbzinwindows, ChrisCatto)
- Add Toggle to launch notification apps in bubble or floating screen (author: shutter-cat)
- Add optional toggleable Classic style QS Panel along with tile shapes and ability to hide labels (author: neobuddy89)
- Allow switching to default Android 16 brightness slider style
- Add detailed Idle manager with advanced per-app control (author: Ghosuto)
- Add 11 more Lockscreen custom clock styles (author: IDontCare-05, spkal01, Ghosuto)
- Fix custom clock styles disappearing on tablets or landscape rotation
- Allow applying volume panel gradient customization to extended volume panel style
- Allow showing Volume percentage on extended and expanded volume panel style 
- Add toggle to kill Flash SMS messages (author: adithya2306)
- Simplify Always-on-Display charging checks (author: NurKeinNeid)
- Remove QS boost hints that lead to battery drain / heat
- Remove unnecessary scrolling boost hints that lead to battery drain / heat
- Add back lockscreen weather wind and humidity info from v3.7
- Remove ongoing media chip // Fixes systemui crash issues while media was playing with media chip enabled
- Add optional Glow effect in notch ring (author: hxreborn)
- Add music playback progress in cutout ring  (author: Ghosuto)
- Improve padding for search icon in app drawer search bar when google app disabled
- Add launcher wallpaper carousel (author: MrSluffy)
- Fix default fonts display for regular and headline in QS Panel
- Fix NPE in CallListener Gamespace (author: neobuddy89)
- Fix scrolling in recovery image when touch is rotated (author: AnierinBliss)
- Allow changing size of custom clock styles (author: Ghosuto)
- Fix PlanesLockGuard buffer lock leak in av (author: jsebechlebsky)
- Fix preferences in launcher3 icon pack fragment turning purple upon clicking (author: neobuddy89)
- Hide VmTerminal fragment if device doesn't support it (author: luk1337)
- Improvements on memory usage and battery backup\"

cat << EOF > release_notes.txt
\$RELEASE_NOTES
EOF

gh release create $TAG_NAME $ZIP_GAPPS boot.img vendor_boot.img dtbo.img --repo $GITHUB_REPO --title \"Project Infinity X | larry | Non-ARB | $TAG_NAME\" -F release_notes.txt

curl -s -X POST \"https://api.telegram.org/bot$TELEGRAM_TOKEN/sendPhoto\" -d chat_id=\"$CHAT_ID\" -d photo=\"$IMAGE_URL\" -d parse_mode=\"HTML\" -d caption=\"$ENCODED_MESSAGE\"

rm -f $ZIP_GAPPS boot.img vendor_boot.img dtbo.img release_notes.txt
"

    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="[WARNING] <b>GitHub Release Failed!</b>%0A%0AThe <code>gh release</code> command has failed. Please open GitHub Codespaces and run the following script. It will download the files from Pixeldrain, push them to GitHub, publish the release, and send the final Telegram post:%0A%0A<pre><code class='language-bash'>$CS_SCRIPT</code></pre>" \
        -d parse_mode="HTML"
        
    exit 1
fi
