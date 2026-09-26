#!/bin/bash
set -euo pipefail

WORLD_NAME="main-world"
SAVE_DIR="/home/factorio/saves"
S3_BUCKET="john-factorio-assets"

inotifywait -m -e close_write --format '%f' "$SAVE_DIR" | while read -r FILE; do
  case "$FILE" in
    _autosave*.zip|*.zip)
      echo "$(date '+%F %T') Detected save write: $FILE"
      aws s3 cp "$SAVE_DIR/$FILE" "s3://$S3_BUCKET/saves/$WORLD_NAME/latest.zip"
      echo "$(date '+%F %T') Synced $FILE to S3"
      ;;
  esac
done
