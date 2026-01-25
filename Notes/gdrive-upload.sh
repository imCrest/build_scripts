#!/bin/bash
set -e

apt update
apt install -y rclone

mkdir -p ~/.config/rclone
[ -f ~/.config/rclone/rclone.conf ] || cp rclone.conf ~/.config/rclone/rclone.conf
[ -f ~/.config/rclone/sa.json ] || exit 1

BASE=~/infinityx/out/target/product
DATE=$(date +%Y-%m-%d)
DEST="gdrive:InfinityX/larry/$DATE"

rclone copy "$BASE/gapps" "$DEST/gapps" \
  --filter "+ /*.zip" \
  --filter "+ /boot.img" \
  --filter "+ /vendor_boot.img" \
  --filter "+ /dtbo.img" \
  --filter "- *" \
  --transfers 1 \
  --checkers 1 \
  --drive-chunk-size 64M \
  --tpslimit 1 \
  --bwlimit 6M \
  -P

rclone copy "$BASE/vanilla" "$DEST/vanilla" \
  --filter "+ /*.zip" \
  --filter "+ /boot.img" \
  --filter "+ /vendor_boot.img" \
  --filter "+ /dtbo.img" \
  --filter "- *" \
  --transfers 1 \
  --checkers 1 \
  --drive-chunk-size 64M \
  --tpslimit 1 \
  --bwlimit 6M \
  -P
