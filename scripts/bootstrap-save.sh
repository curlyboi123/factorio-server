#!/bin/bash
set -euo pipefail

WORLD_NAME="main-world"
S3_BUCKET="john-factorio-assets"
FACTORIO_DIR="/home/factorio"

mkdir -p "$FACTORIO_DIR/saves"

if aws s3api head-object --bucket "$S3_BUCKET" --key "factorio-saves/$WORLD_NAME/latest.zip" >/dev/null 2>&1; then
  echo "Existing world found — restoring save"
  aws s3 cp "s3://$S3_BUCKET/factorio-saves/$WORLD_NAME/latest.zip" "$FACTORIO_DIR/saves/latest.zip"
else
  echo "New world — no save to restore, factorio.service will create one"
fi
