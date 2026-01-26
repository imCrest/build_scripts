#!/bin/bash

# =============================
#   InfinityX Build Script
#   For: Vanilla + Gapps
# =============================


# --- Init ROM repo ---
repo init -u https://github.com/ProjectInfinity-X/manifest -b 16 --git-lfs && \

# --- Sync ROM ---
/opt/crave/resync.sh && \

# --- Clone Device Tree ---
git clone https://github.com/imCrest/android_device_oneplus_larry -b infinityx device/oneplus/larry && \

# --- Clone Common Device Tree ---
git clone https://github.com/imCrest/android_device_oneplus_sm6375-common -b lineage-23.1 device/oneplus/sm6375-common && \

# --- Clone Vendor Tree ---
git clone https://github.com/imCrest/proprietary_vendor_oneplus_larry -b lineage-23.1 vendor/oneplus/larry && \

# --- Clone Common Vendor Tree ---
git clone https://github.com/imCrest/proprietary_vendor_oneplus_sm6375-common -b lineage-23.1 vendor/oneplus/sm6375-common && \

# --- Clone Kernel Tree ---
git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-23.1 kernel/oneplus/sm6375 && \

# --- Clone Hardware Tree ---
git clone https://github.com/imCrest/android_hardware_oplus -b lineage-23.1 hardware/oplus && \


export WITH_GMS=true
export TARGET_SUPPORTS_GAPPS=true
export TARGET_SUPPORTS_GSUITE=true

rm -rf out/soong out/target/product/larry
source build/envsetup.sh
lunch infinity_larry-userdebug
mka bacon -j$(nproc)
mv out/target/product/larry out/target/product/gapps

export WITH_GMS=false
export TARGET_SUPPORTS_GAPPS=false
export TARGET_SUPPORTS_GSUITE=false

rm -rf out/soong out/target/product/larry
source build/envsetup.sh
lunch infinity_larry-userdebug
mka bacon -j$(nproc)
mv out/target/product/larry out/target/product/vanilla
