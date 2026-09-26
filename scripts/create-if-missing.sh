if [ ! -f /home/factorio/saves/latest.zip ]; then
  /home/factorio/factorio/bin/x64/factorio --create /home/factorio/saves/latest.zip \
    --map-gen-settings /home/factorio/config/map-gen-settings.json \
    --map-settings /home/factorio/config/map-settings.json
fi
