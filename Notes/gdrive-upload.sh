#!/bin/bash
set -e

export TZ=Asia/Kolkata

sudo apt update
sudo apt install -y rclone

if ! rclone listremotes | grep -q "^gdrive:"; then
  rclone config
fi

BASE_DIR="$HOME/infinityx/out/target/product"

VANILLA_DIR="$BASE_DIR/vanilla"
GAPPS_DIR="$BASE_DIR/gapps"

if [ -d "$VANILLA_DIR" ]; then
  for zip in "$VANILLA_DIR"/*.zip; do
    [ -e "$zip" ] || continue
    rclone copy "$zip" gdrive:InfinityX/larry/vanilla -P --retries 5
  done
fi

if [ -d "$GAPPS_DIR" ]; then
  for zip in "$GAPPS_DIR"/*.zip; do
    [ -e "$zip" ] || continue
    rclone copy "$zip" gdrive:InfinityX/larry/gapps -P --retries 5
  done
fi

echo "Upload done"
