#!/bin/bash

repo init -u https://github.com/ProjectInfinity-X/manifest -b 16 --git-lfs && \
/opt/crave/resync.sh && \
git clone https://github.com/imCrest/android_device_oneplus_larry -b infinityx device/oneplus/larry && \
git clone https://github.com/imCrest/android_device_oneplus_sm6375-common -b lineage-23.2 device/oneplus/sm6375-common && \
git clone https://github.com/imCrest/proprietary_vendor_oneplus_larry -b lineage-23.2 vendor/oneplus/larry && \
git clone https://github.com/imCrest/proprietary_vendor_oneplus_sm6375-common -b lineage-23.2 vendor/oneplus/sm6375-common && \
git clone https://github.com/imCrest/android_kernel_oneplus_sm6375 -b lineage-23.2 kernel/oneplus/sm6375 && \
git clone https://github.com/imCrest/android_hardware_oplus -b lineage-23.2 hardware/oplus && \

. build/envsetup.sh && \
lunch infinity_larry-userdebug && \
make installclean && \
m bacon && \
mv device/oneplus/larry/infinity_larry.mk device/oneplus/larry/vanilla.txt && \
mv out/target/product/larry out/target/product/vanilla && \

mv device/oneplus/larry/gapps.txt device/oneplus/larry/infinity_larry.mk && \
make installclean && \
m bacon && \
mv device/oneplus/larry/infinity_larry.mk device/oneplus/larry/gapps.txt && \
mv out/target/product/larry out/target/product/gapps && \
mv device/oneplus/larry/vanilla.txt device/oneplus/larry/infinity_larry.mk
