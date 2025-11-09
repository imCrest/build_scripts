#!/usr/bin/env bash
#
# build_script.sh — Full auto dual build (Vanilla + GApps) for OnePlus Larry
#

set -euo pipefail

DEVICE="larry"
TARGET="infinity_${DEVICE}-userdebug"
OUT="out/target/product/${DEVICE}"
JOBS="$(nproc || echo 8)"
STAGE="${HOME}/Downloads"

# 💾 Repo init + sync
echo "🔄 Initializing repo..."
repo init -u https://github.com/ProjectInfinity-X/manifest -b 16 --git-lfs
/opt/crave/resync.sh

# 📦 Clone trees
echo "📂 Cloning device, vendor, kernel trees..."
git clone https://github.com/imCrest/android_device_oneplus_larry -b infinityx device/oneplus/larry
git clone https://github.com/anshedu/android_device_oneplus_sm6375-common -b infinityx16 device/oneplus/sm6375-common
git clone https://github.com/anshedu/proprietary_vendor_oneplus_larry -b infinityx16 vendor/oneplus/larry
git clone https://github.com/anshedu/proprietary_vendor_oneplus_sm6375-common -b infinityx16 vendor/oneplus/sm6375-common
git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-22.2 kernel/oneplus/sm6375
git clone https://github.com/LineageOS/android_hardware_oplus -b lineage-23.0 hardware/oplus

# 🧠 Environment
source build/envsetup.sh
lunch "${TARGET}"

# ⚙️ Helper: clean + move zip
function clean_and_stage() {
  local tag="$1"
  make installclean -j"${JOBS}"
  rm -rf "${OUT}/obj/KERNEL_OBJ" 2>/dev/null || true
  local z
  z="$(ls -1t ${OUT}/*.zip 2>/dev/null | head -n1 || true)"
  if [[ -n "$z" ]]; then
    mkdir -p "${STAGE}"
    cp -f "$z" "${STAGE}/$(basename "${z%.zip}")-${tag^^}.zip"
    echo "✅ Copied: $(basename "${z%.zip}")-${tag^^}.zip"
  fi
}

# 🧱 VANILLA BUILD
echo "⚙️ Building VANILLA (no GApps)..."
export WITH_GMS=false
export TARGET_GAPPS=false TARGET_INCLUDE_GOOGLE_APPS=false
mka bacon -j"${JOBS}"
clean_and_stage "vanilla"

# 🧱 GAPPS BUILD
echo "⚙️ Building GAPPS..."
unset WITH_GMS TARGET_GAPPS TARGET_INCLUDE_GOOGLE_APPS
mka bacon -j"${JOBS}"
clean_and_stage "gapps"

# ✅ Done
echo "🎉 Builds finished successfully!"
echo "📁 Check your ${STAGE} folder for both zips."
