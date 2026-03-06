#!/bin/bash

repo init --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16 -g default,-mips,-darwin,-notdefault && \
/opt/crave/resync.sh && \
git clone https://github.com/imCrest/android_device_oneplus_larry -b infinityx device/oneplus/larry && \
git clone https://github.com/imCrest/android_device_oneplus_sm6375-common -b lineage-23.2 device/oneplus/sm6375-common && \
git clone https://github.com/imCrest/proprietary_vendor_oneplus_larry -b lineage-23.2 vendor/oneplus/larry && \
git clone https://github.com/imCrest/proprietary_vendor_oneplus_sm6375-common -b lineage-23.2 vendor/oneplus/sm6375-common && \
git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-23.2 kernel/oneplus/sm6375 && \
git clone https://github.com/imCrest/android_hardware_oplus -b lineage-23.2 hardware/oplus && \

export WITH_GMS=true && \
export TARGET_SUPPORTS_GAPPS=true && \
export TARGET_SUPPORTS_GSUITE=true && \
source build/envsetup.sh && \
lunch infinity_larry-userdebug && \
make installclean && \
mka bacon -j$(nproc) && \
mv out/target/product/larry out/target/product/gapps && \

export WITH_GMS=false && \
export TARGET_SUPPORTS_GAPPS=false && \
export TARGET_SUPPORTS_GSUITE=false && \
source build/envsetup.sh && \
lunch infinity_larry-userdebug && \
make installclean && \
mka bacon -j$(nproc) && \
mv out/target/product/larry out/target/product/vanilla

PIXELDRAIN_KEY="f869dbb7-758e-4efa-9440-e1418b1c9916"

cd out/target/product/gapps
curl -T *.zip -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/
curl -T boot.img -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/
curl -T vendor_boot.img -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/
curl -T dtbo.img -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/

cd ../vanilla
curl -T *.zip -u :$PIXELDRAIN_KEY https://pixeldrain.com/api/file/
