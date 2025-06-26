#! /bin/bash

rm -rf .repo/local_manifests; \
rm -rf {device,vendor,kernel,hardware}/oneplus && \
repo init --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 15 -g default,-mips,-darwin,-notdefault && \
/opt/crave/resync.sh && \
git clone https://github.com/anshedu/android_device_oneplus_larry -b InfinityX device/oneplus/larry && \
git clone https://github.com/anshedu/android_device_oneplus_sm6375-common -b InfinityX device/oneplus/sm6375-common && \
git clone https://github.com/anshedu/proprietary_vendor_oneplus_larry -b lineage-22.2 vendor/oneplus/larry && \
git clone https://github.com/anshedu/proprietary_vendor_oneplus_sm6375-common -b lineage-22.2 vendor/oneplus/sm6375-common && \
git clone https://github.com/anshedu/android_kernel_oneplus_sm6375 -b lineage-22.2 kernel/oneplus/sm6375 && \
git clone https://github.com/anshedu/hardware_oplus -b fifteen hardware/oplus && \
# Vanilla Build
. build/envsetup.sh && \
lunch larry user && make installclean && mka bacon; \
cd out/target/product && mv larry vanilla && cd ../../..; \
# Gapps Build
cd device/oneplus/larry && rm infinity_larry.mk && mv gapps.txt infinity_larry.mk && cd ../../..; \
. build/envsetup.sh; \
lunch larry user && make installclean && mka bacon; \
cd out/target/product && mv larry gapps && cd ../../..; \
