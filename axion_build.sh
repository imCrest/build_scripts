#!/usr/bin/env bash
# axion_build.sh — AxionOS dual build (Vanilla + GApps) for OnePlus larry

set -euo pipefail

DEVICE="larry"
TARGET="axion_${DEVICE}-userdebug"            # product name (defined below in axion_larry.mk)
OUT="out/target/product/${DEVICE}"
JOBS="$(nproc || echo 8)"
STAGE="${HOME}/Downloads"

# Speed-ups
export USE_CCACHE=1
export CCACHE_DIR="${HOME}/.ccache"
command -v ccache >/dev/null 2>&1 && ccache -M 50G || true

echo "🔄 repo init AxionOS (Android 15 / Lineage 23.0)…"
repo init -u https://github.com/AxionAOSP/android.git -b lineage-23.0 --git-lfs
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

echo "📂 cloning device/vendor/kernel trees…"
# 🧠 RECOMMENDED: apni device repo ka ek naya branch banao (e.g., axion-23.0) with the mk below
git clone https://github.com/sahusujall/android_device_oneplus_larry -b axion-23.0 device/oneplus/larry

# adjust these to your known-good branches for Android 15/Lineage 23 if needed:
git clone https://github.com/anshedu/android_device_oneplus_sm6375-common -b lineage-23.0 device/oneplus/sm6375-common || true
git clone https://github.com/anshedu/proprietary_vendor_oneplus_larry -b lineage-23.0 vendor/oneplus/larry || true
git clone https://github.com/anshedu/proprietary_vendor_oneplus_sm6375-common -b lineage-23.0 vendor/oneplus/sm6375-common || true
git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-22.2 kernel/oneplus/sm6375 || true
git clone https://github.com/LineageOS/android_hardware_oplus -b lineage-23.0 hardware/oplus || true

echo "🧠 envsetup + lunch ${TARGET}…"
source build/envsetup.sh
lunch "${TARGET}"

stage_zip () {
  local tag="$1"
  mkdir -p "${STAGE}"
  local z
  z="$(ls -1t "${OUT}"/*.zip 2>/dev/null | head -n1 || true)"
  [[ -z "${z}" ]] && { echo "❌ No zip found in ${OUT}"; exit 1; }
  local base="$(basename "${z}" .zip)"
  local dest="${STAGE}/${base}-${tag^^}.zip"
  chmod +r "${z}" || true
  cp -f "${z}" "${dest}"
  echo "✅ Staged → ${dest}"
}

light_clean () {
  echo "🧹 installclean…"
  make installclean -j"${JOBS}" || true
  rm -rf "${OUT}/obj/KERNEL_OBJ" 2>/dev/null || true
}

# ---------- VANILLA ----------
echo "⚙️ Building VANILLA (no GApps)…"
export WITH_GMS=false
export TARGET_GAPPS=false TARGET_INCLUDE_GOOGLE_APPS=false
light_clean
mka bacon -j"${JOBS}"
stage_zip vanilla

# ---------- GAPPS ----------
echo "⚙️ Building GAPPS…"
unset WITH_GMS TARGET_GAPPS TARGET_INCLUDE_GOOGLE_APPS
light_clean
mka bacon -j"${JOBS}"
stage_zip gapps

echo "🎉 Done! Check ${STAGE} for -VANILLA and -GAPPS zips."
