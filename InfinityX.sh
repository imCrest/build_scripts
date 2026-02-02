#!/bin/bash

# =============================
# InfinityX Build Script
# Fast version for Crave.io
# =============================

# --- Init ROM repo ---
repo init --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16 -g default,-mips,-darwin,-notdefault && \
# --- Sync ROM ---
/opt/crave/resync.sh && \
# --- Clone Device Tree ---
git clone https://github.com/imCrest/android_device_oneplus_larry -b infinityx device/oneplus/larry && \
# --- Clone Common Device Tree ---
git clone https://github.com/imCrest/android_device_oneplus_sm6375-common -b lineage-23.2 device/oneplus/sm6375-common && \
# --- Clone Vendor Tree ---
git clone https://github.com/imCrest/proprietary_vendor_oneplus_larry -b lineage-23.2 vendor/oneplus/larry && \
# --- Clone Common Vendor Tree ---
git clone https://github.com/imCrest/proprietary_vendor_oneplus_sm6375-common -b lineage-23.2 vendor/oneplus/sm6375-common && \
# --- Clone Kernel Tree ---
git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-23.2 kernel/oneplus/sm6375 && \
# --- Clone Hardware Tree ---
git clone https://github.com/imCrest/android_hardware_oplus -b lineage-23.2 hardware/oplus && \

# =============================
# Build: Gapps → Vanilla
# =============================

# --- Gapps Build ---
echo "===== Starting Gapps Build =====" && \
export WITH_GMS=true && \
export TARGET_SUPPORTS_GAPPS=true && \
export TARGET_SUPPORTS_GSUITE=true && \
source build/envsetup.sh && \
lunch infinity_larry-userdebug && \
make installclean && \
mka bacon -j$(nproc) && \
mv out/target/product/larry out/target/product/gapps && \

# --- Vanilla Build ---
echo "===== Starting Vanilla Build =====" && \
export WITH_GMS=false && \
export TARGET_SUPPORTS_GAPPS=false && \
export TARGET_SUPPORTS_GSUITE=false && \
source build/envsetup.sh && \
lunch infinity_larry-userdebug && \
make installclean && \
mka bacon -j$(nproc) && \
mv out/target/product/larry out/target/product/vanilla && \

echo "===== All builds completed successfully! ====="
