#! /bin/bash

rm -rf .repo/local_manifests; \
rm -rf {device,vendor,kernel,hardware}/oneplus && \
repo init --depth=1 --no-repo-verify -u https://github.com/Evolution-X/manifest -b vic --git-lfs -g default,-mips,-darwin,-notdefault && \
/opt/crave/resync.sh && \
git clone https://github.com/anshedu/android_device_oneplus_larry -b lineage-22.2 device/oneplus/larry && \
git clone https://github.com/anshedu/android_device_oneplus_sm6375-common -b lineage-22.2 device/oneplus/sm6375-common && \
git clone https://github.com/anshedu/proprietary_vendor_oneplus_larry -b lineage-22.2 vendor/oneplus/larry && \
git clone https://github.com/anshedu/proprietary_vendor_oneplus_sm6375-common -b lineage-22.2 vendor/oneplus/sm6375-common && \
git clone https://github.com/anshedu/android_kernel_oneplus_sm6375 -b lineage-22.2 kernel/oneplus/sm6375 && \
git clone https://github.com/anshedu/android_hardware_oplus -b lineage-22.2 hardware/oplus && \
# Vanilla Build
. build/envsetup.sh && \
breakfast larry user && make installclean && mka bacon; \
rm -rf out/target/product/vanilla && rm -rf out/target/product/gapps; \
cd out/target/product && mv larry vanilla && cd ../../..; \
# Gapps Build
cd device/oneplus/larry && rm lineage_larry.mk && mv gapps.txt lineage_larry.mk && cd ../../..; \
. build/envsetup.sh; \
breakfast larry user && make installclean && mka bacon; \
cd out/target/product && mv larry gapps && cd ../../..; \
