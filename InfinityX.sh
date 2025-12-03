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
git clone https://github.com/imCrest/android_device_oneplus_sm6375-common1 -b lineage-23.0 device/oneplus/sm6375-common && \

# --- Clone Vendor Tree ---
git clone https://github.com/imCrest/proprietary_vendor_oneplus_larry -b lineage-23.0 vendor/oneplus/larry && \

# --- Clone Common Vendor Tree ---
git clone https://github.com/imCrest/proprietary_vendor_oneplus_sm6375-common -b lineage-23.0 vendor/oneplus/sm6375-common && \

# --- Clone Kernel Tree ---
git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-23.0 kernel/oneplus/sm6375 && \

# --- Clone Hardware Tree ---
git clone https://github.com/LineageOS/android_hardware_oplus -b lineage-23.0 hardware/oplus && \

# =============================
#  Build: Vanilla → Gapps
# =============================

# --- Vanilla Build ---
echo "===== Starting Vanilla Build ====="
. build/envsetup.sh && \
lunch infinity_larry-userdebug && \
make installclean && \
m bacon && \
mv device/oneplus/larry/infinity_larry.mk device/oneplus/larry/vanilla.txt && \

echo "===== Handling Vanilla Output ====="
mv out/target/product/larry out/target/product/vanilla && \

# --- Gapps Build ---
echo "===== Setting up for Gapps Build ====="
mv device/oneplus/larry/gapps.txt device/oneplus/larry/infinity_larry.mk && \
make installclean && \
m bacon && \
mv device/oneplus/larry/infinity_larry.mk device/oneplus/larry/gapps.txt && \

echo "===== Handling Gapps Output ====="
mv out/target/product/larry out/target/product/gapps && \

# --- Restore Vanilla ---
mv device/oneplus/larry/vanilla.txt device/oneplus/larry/infinity_larry.mk && \

echo "===== All builds completed successfully! ====="
