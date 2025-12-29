#!/bin/bash
set -e

# =============================
#   InfinityX Build Script
#   Repo v2.60+ Safe
#   Vanilla + Gapps
# =============================

echo "===== Initializing Repo ====="

repo init -u https://github.com/ProjectInfinity-X/manifest -b 16 --git-lfs

echo "===== Cleaning old repo state (hooks / dirty fixes) ====="

# Fix repo v2.60+ hook mismatch & dirty projects
repo forall -c 'git reset --hard || true'
repo forall -c 'git clean -fdx || true'

# Remove problematic prebuilts if partially synced
rm -rf prebuilts/clang/host/linux-x86 || true
rm -rf external/chromium-webview || true

echo "===== Syncing ROM Source ====="
/opt/crave/resync.sh

echo "===== Cloning Device / Vendor / Kernel Trees ====="

# --- Device Tree ---
git clone https://github.com/imCrest/android_device_oneplus_larry -b infinityx device/oneplus/larry

# --- Common Device Tree ---
git clone https://github.com/imCrest/android_device_oneplus_sm6375-common1 -b lineage-23.0 device/oneplus/sm6375-common

# --- Vendor Tree ---
git clone https://github.com/imCrest/proprietary_vendor_oneplus_larry -b lineage-23.0 vendor/oneplus/larry

# --- Common Vendor Tree ---
git clone https://github.com/imCrest/proprietary_vendor_oneplus_sm6375-common -b lineage-23.0 vendor/oneplus/sm6375-common

# --- Kernel Tree ---
git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-23.0 kernel/oneplus/sm6375

# --- Hardware Tree ---
git clone https://github.com/LineageOS/android_hardware_oplus -b lineage-23.0 hardware/oplus

# =============================
#  Build Section
# =============================

echo "===== Setting up build env ====="
. build/envsetup.sh
lunch infinity_larry-userdebug

# ---------- VANILLA ----------
echo "===== Starting VANILLA Build ====="
make installclean
m bacon

echo "===== Saving Vanilla Output ====="
mv device/oneplus/larry/infinity_larry.mk device/oneplus/larry/vanilla.txt
mv out/target/product/larry out/target/product/vanilla

# ---------- GAPPS ----------
echo "===== Starting GAPPS Build ====="
mv device/oneplus/larry/gapps.txt device/oneplus/larry/infinity_larry.mk
make installclean
m bacon

echo "===== Saving Gapps Output ====="
mv out/target/product/larry out/target/product/gapps
mv device/oneplus/larry/infinity_larry.mk device/oneplus/larry/gapps.txt

# ---------- RESTORE ----------
mv device/oneplus/larry/vanilla.txt device/oneplus/larry/infinity_larry.mk

echo "===== ALL BUILDS COMPLETED SUCCESSFULLY ====="
