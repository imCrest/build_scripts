#!/bin/bash
set -e

apt update
apt install -y rclone curl

mkdir -p ~/.config/rclone

cat > ~/.config/rclone/sa.json <<'EOF'
{
  "type": "service_account",
  "project_id": "infinityx-upload",
  "private_key_id": "d204d3205ec5d9d86aa45d890b3c0e7e8ac0dfce",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCX55H+8AWrnItU\nERVc8i/mAQR3OBXLpnF74pSi2xfBf5Tdln6jiVKOSh8YfjXQKovc9SgY4nv5eQj6\nM1ijapiONrP/mXaUJweYFGBvUEPTvhxiMDLeHfVrd6fICZ6HDf31E7xrGfaUC+gL\nYyBKSk8FdmO97Rr+P46dXIH1ruZxzXl6XxB/DGVOvHelTWucloiJSz1bNGApxCpr\n4Qktz+fzmjaWpfzsiJwRChWoRKoG33vQr64Crhh/67SvoMXrK6O6IGdSX+fubvKp\nWfI7UfA6GBhesr8iUhe5HhFoW7NCvNWm0S1tevr0V2lVUXehi1uRWod43yAfErd0\nPbNNlJrjAgMBAAECggEAL5oAlSwwCrQWsTRdRnAadHATLyzjH5s76r95JoOTsS5C\nvyGe865fsXkmv20lfeMnSwmEFDA8+1NjbcxTVXpc7gvUYh98GjcU2SJhieBUMPFd\nQaOq/RHUS2YGrNfe1qGa2Ibjv4g2TfRhNdhNURpyItsTrHu1vsC59zP7AbtaOYTX\nY0u3X7yn41GPoJR0zH+JvPoMrt2GCS/4SQrPDktRQP+q27dyMLcR0UPy+ESAeo1S\nvZmAbSLT8bLqNTnPXtlTSRatYbN0tt7noffNYlnu/O6ZuBWcKUXP8nKOaj4DZX16\nI/gplld+WCU6cfpk+/klwZ4asZJajZzUcvEPOBSGuQKBgQDRHMV1NT871yR0wqbJ\npHqWmikem+AeDPulWB1h+U4oPqBSOrTiQv90mic42zbWKRp/aVtouJ8v5bz3LAXs\nqmCNk4guZ/lI+0L70opVgHXluA0KxM4D3jfnOhV+1lLumns/Nk2yqQ15wGlKyjwY\nKxKyqpEsOU20aW+8gxtBRfG89QKBgQC59wWPbZn1jKrCgBMAWDZku7ENMoGIkehA\nKAgcg8tDLLGlF8pJ0QXJwi32igWtrzOZdHogoiKKW6VZTcEo2SxKEEg9MvBB9GK3\n0OwEKkU+dw3MwrNnOfS0GgiGPqkzgUQsLf60Y1wB386f5KlDAypku08uGl742sdK\neTMSeBORdwKBgQCzKfqIZNnL1JZ4r7oldBZQaL8oaZdJSAhn7yolomvzkUzdh00p\nuwuShO1sCm5eaZM5bTSTcfN6H1WbVQ2ya3wUcT4xvIXaoOUQS6CYh1r8Ooh6HIsC\nx2eQZrS6Grmtk5BbZZSGqc9Q7KmKGeIJNwZrLDb79BD+rYO9uXslnt7y7QKBgQCj\npFHKQsIGJ8Bj41vVI8rJnbhRSq5dxTdArXllzjvhYsT36BVkG4EiZ7MWjaItkkyv\nrqWBbetDIR5BlYByN5kXm3hWEisFfs4XvsrRZ3kDXLRSCMrh/Uft7DKwHxe5cPjS\nf67wgbaHF7C1VvvzMift+D3W7fHAvpQ8Xqaoi+18RQKBgChaKre5ekgSgFSvfoF1\nMrb8lIqVdazw5kiCOwLnzecoIdlIr5wIwkdSSh5d+HAf1SppUc9r79fJ6HOmrTfc\n9/xHKFeqg21DrPd8HNN9hTvuLUmskJ6slSyRp95lt0me2LuGHMAPkClBVx8bs56R\nn78asawnUWmcXtwWBc5Nmt4b\n-----END PRIVATE KEY-----\n",
  "client_email": "infinityx-uploader@infinityx-upload.iam.gserviceaccount.com",
  "client_id": "105137356327056738513",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/infinityx-uploader%40infinityx-upload.iam.gserviceaccount.com"
}
EOF

BASE="$HOME/infinityx/out/target/product"
DATE=$(date +%Y-%m-%d)
DEST="gdrive:InfinityX/larry/$DATE"

rclone copy "$BASE/gapps" "$DEST/gapps" \
  --filter "+ /*.zip" \
  --filter "+ /boot.img" \
  --filter "+ /vendor_boot.img" \
  --filter "+ /dtbo.img" \
  --filter "- *" \
  --drive-service-account-file ~/.config/rclone/sa.json \
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
  --drive-service-account-file ~/.config/rclone/sa.json \
  --transfers 1 \
  --checkers 1 \
  --drive-chunk-size 64M \
  --tpslimit 1 \
  --bwlimit 6M \
  -P
