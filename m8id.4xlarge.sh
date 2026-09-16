#!/usr/bin/env bash
set -e

EPHEMERAL_DISK=$(lsblk -d -n -o NAME,TYPE | grep -E '^nvme' | grep 'disk' | grep -v 'nvme0n1' | head -n1 | awk '{print "/dev/"$1}')

if [ -z "$EPHEMERAL_DISK" ] && [ -b "/dev/nvme1n1" ]; then
    EPHEMERAL_DISK="/dev/nvme1n1"
fi

if [ -n "$EPHEMERAL_DISK" ]; then
    if ! lsblk -f "$EPHEMERAL_DISK" | grep -q "ext4"; then
        sudo mkfs.ext4 -F "$EPHEMERAL_DISK"
    fi
    sudo mkdir -p /mnt/build
    if ! grep -qs '/mnt/build' /proc/mounts; then
        sudo mount -o defaults,noatime "$EPHEMERAL_DISK" /mnt/build
    fi
    sudo chown -R "$USER":"$USER" /mnt/build
    mkdir -p /mnt/build/infinityx /mnt/build/.ccache
    rm -rf "$HOME/infinityx" "$HOME/.ccache"
    ln -sfn /mnt/build/infinityx "$HOME/infinityx"
    ln -sfn /mnt/build/.ccache "$HOME/.ccache"
else
    mkdir -p "$HOME/infinityx" "$HOME/.ccache"
fi

sudo apt update
sudo apt install -y git git-lfs curl zip unzip bc bison build-essential clang \
ccache flex g++-multilib gcc-multilib gnupg gperf imagemagick lib32readline-dev \
lib32z1-dev lz4 libncurses-dev libssl-dev libxml2-utils lzop openjdk-17-jdk \
python-is-python3 python3-pip python3-setuptools python3-yaml rsync schedtool \
squashfs-tools xsltproc zlib1g-dev tmux rclone

git lfs install

mkdir -p "$HOME/bin"
curl -s https://storage.googleapis.com/git-repo-downloads/repo > "$HOME/bin/repo"
chmod +x "$HOME/bin/repo"

ENV_VARS='export PATH=$HOME/bin:$PATH
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_DIR=$HOME/.ccache
export CCACHE_BASEDIR=$HOME/infinityx
export CCACHE_COMPRESS=1
export CCACHE_COMPRESSLEVEL=6
export CCACHE_SLOPPINESS=time_macros'

grep -q "USE_CCACHE" "$HOME/.bashrc" || echo "$ENV_VARS" >> "$HOME/.bashrc"

export PATH="$HOME/bin:$PATH"
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_DIR="$HOME/.ccache"
export CCACHE_BASEDIR="$HOME/infinityx"
export CCACHE_COMPRESS=1
export CCACHE_COMPRESSLEVEL=6
export CCACHE_SLOPPINESS=time_macros

ccache -M 150G
ccache -z

cd "$HOME/infinityx"
