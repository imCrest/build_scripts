#!/usr/bin/env bash
# axion_build.sh — AxionOS dual build (Vanilla + GApps) for OnePlus larry

set -euo pipefail

DEVICE="larry"
TARGET="axion_${DEVICE}-userdebug"
OUT="out/target/product/${DEVICE}"
JOBS="$(nproc || echo 8)"
STAGE="${HOME}/Downloads"

# Speed-ups
export USE_CCACHE=1
export CCACHE_DIR="${HOME}/.ccache"
command -v ccache >/dev/null 2>&1 && ccache -M 50G || true

log() { echo -e "\n\033[1;36m[$(date +'%F %T')] $*\033[0m"; }
die() { echo -e "\n\033[1;31mERROR:\033[0m $*" >&2; exit 1; }

pick_zip() {
  # returns newest product zip path or dies
  local z
  z="$(ls -1t "${OUT}"/*.zip 2>/dev/null | head -n1 || true)"
  [[ -z "${z}" ]] && die "No zip found in ${OUT}"
  printf "%s" "${z}"
}

stage_zip() {
  local tag="$1"
  mkdir -p "${STAGE}"
  local z base dest
  z="$(pick_zip)"
  base="$(basename "${z}" .zip)"
  dest="${STAGE}/${base}-${tag^^}.zip"
  chmod +r "${z}" || true
  cp -f "${z}" "${dest}"
  log "✅ Staged → ${dest}"
}

light_clean() {
  log "🧹 installclean"
  make installclean -j"${JOBS}" || true
  rm -rf "${OUT}/obj/KERNEL_OBJ" 2>/dev/null || true
}

log "🔄 repo init AxionOS (lineage-23.0)…"
repo init -u https://github.com/AxionAOSP/android.git -b lineage-23.0 --git-lfs
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8

log "📂 cloning device/vendor/kernel trees…"
# Device tree on your new branch:
git clone https://github.com/sahusujall/android_device_oneplus_larry -b axion-23.0 device/oneplus/larry

# Common/vendor/kernel — adjust to your known-good lineage-23.0 branches if needed
git clone https://github.com/anshedu/android_device_oneplus_sm6375-common -b lineage-23.0 device/oneplus/sm6375-common || true
git clone https://github.com/anshedu/proprietary_vendor_oneplus_larry -b lineage-23.0 vendor/oneplus/larry || true
git clone https://github.com/anshedu/proprietary_vendor_oneplus_sm6375-common -b lineage-23.0 vendor/oneplus/sm6375-common || true
git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-22.2 kernel/oneplus/sm6375 || true
git clone https://github.com/LineageOS/android_hardware_oplus -b lineage-23.0 hardware/oplus || true

log "🧠 envsetup + lunch ${TARGET}"
source build/envsetup.sh
lunch "${TARGET}" >/dev/null || die "lunch ${TARGET} failed"

# ---------- VANILLA ----------
log "⚙️ Building VANILLA (no GApps)…"
export WITH_GMS=false
export TARGET_GAPPS=false TARGET_INCLUDE_GOOGLE_APPS=false
light_clean
mka bacon -j"${JOBS}"
stage_zip "vanilla"

# ---------- GAPPS ----------
log "⚙️ Building G A P P S …"
unset WITH_GMS TARGET_GAPPS TARGET_INCLUDE_GOOGLE_APPS
light_clean
mka bacon -j"${JOBS}"
stage_zip "gapps"

log "🎉 Done! Check ${STAGE} for -VANILLA and -GAPPS zips."
