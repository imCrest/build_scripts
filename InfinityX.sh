#!/bin/bash
set -e

# --- Init & sync ---
repo init -u https://github.com/ProjectInfinity-X/manifest -b 16 --git-lfs
/opt/crave/resync.sh

# --- Trees ---
git clone https://github.com/imCrest/android_device_oneplus_larry -b lineage-22.2 device/oneplus/larry
git clone https://github.com/anshedu/android_device_oneplus_sm6375-common -b infinityx16 device/oneplus/sm6375-common
git clone https://github.com/anshedu/proprietary_vendor_oneplus_larry -b lineage-23.0 vendor/oneplus/larry
git clone https://github.com/anshedu/proprietary_vendor_oneplus_sm6375-common -b lineage-23.0 vendor/oneplus/sm6375-common
git clone https://github.com/anshedu/android_kernel_oneplus_sm6375 -b lineage-23.0 kernel/oneplus/sm6375
git clone https://github.com/LineageOS/android_hardware_oplus -b lineage-23.0 hardware/oplus

# --- Setup ---
source build/envsetup.sh
lunch infinity_larry-userdebug

# A helper to copy the built zip somewhere without killing the product dir
stage_zip () {
  local tag="$1"  # "vanilla" or "gapps"
  mkdir -p out/target/product/"$tag"
  # pick newest zip
  local z
  z="$(ls -1t out/target/product/larry/*.zip | head -n1)"
  cp -f "$z" "out/target/product/$tag/"
  echo "✅ staged $(basename "$z") -> out/target/product/$tag/"
}

echo "===== Starting VANILLA build ====="
# put VANILLA mk in place *before* building
mv device/oneplus/larry/infinity_larry.mk device/oneplus/larry/gapps.txt
mv device/oneplus/larry/vanilla.txt device/oneplus/larry/infinity_larry.mk

# optionally force no-GMS to be extra sure
export WITH_GMS=false
export TARGET_GAPPS=false
export TARGET_INCLUDE_GOOGLE_APPS=false

make installclean
mka bacon
stage_zip vanilla

echo "===== Starting GAPPS build ====="
# swap back to GAPPS mk *before* building
mv device/oneplus/larry/infinity_larry.mk device/oneplus/larry/vanilla.txt
mv device/oneplus/larry/gapps.txt device/oneplus/larry/infinity_larry.mk

unset WITH_GMS TARGET_GAPPS TARGET_INCLUDE_GOOGLE_APPS
make installclean
mka bacon
stage_zip gapps

echo "===== All builds completed successfully! ====="
