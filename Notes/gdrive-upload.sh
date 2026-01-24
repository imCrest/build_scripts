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
  rclone copy "$VANILLA_DIR" gdrive:InfinityX/larry/vanilla -P --retries 5
fi

if [ -d "$GAPPS_DIR" ]; then
  rclone copy "$GAPPS_DIR" gdrive:InfinityX/larry/gapps -P --retries 5
fi

echo "Upload done"
