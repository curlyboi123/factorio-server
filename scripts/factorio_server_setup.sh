#!/bin/bash
set -euo pipefail

VERSION="2.0.77"
BUILD="headless"
DISTRO="linux64"
FACTORIO_PACKAGE_NAME="${VERSION}.tar.xz"
SPACE_AGE_DLC_ENABLED=false

dnf install -y inotify-tools

# Download Factorio package
curl https://www.factorio.com/get-download/${VERSION}/${BUILD}/${DISTRO} \
    -L \
    --output /tmp/${FACTORIO_PACKAGE_NAME}

# Extract package
cd /opt/
sudo tar -xJf /tmp/${FACTORIO_PACKAGE_NAME}

# Remove Space Age files if user does not have to avoid conflict with mods.
space_age_files=("data/elevated-rails" "data/quality" "data/space-age")
if [ "$SPACE_AGE_DLC_ENABLED" = false ] ; then
    echo "Space Age DLC disabled"
    echo "Removing Space Age files"
    for i in "${space_age_files[@]}"
    do
        rm -rf /opt/factorio/$i
    done
fi

# Create Factorio system user
useradd factorio
chown -R factorio:factorio /opt/factorio

# Login to Factorio user
su factorio

FACTORIO_DIR="/home/factorio"

# Download Factorio config from S3 bucket
config_dir="$FACTORIO_DIR/config"
save_dir="$FACTORIO_DIR/saves"

mkdir -p $config_dir
mkdir -p $save_dir
chown factorio:factorio $FACTORIO_DIR

bucket="s3://john-factorio-assets"

config_files=("server-settings.json" "map-gen-settings.json" "map-settings.json")
for i in "${config_files[@]}"
do
    aws s3 cp $bucket/config/$i $config_dir/$i
done

world_name="world_1"
save_file="/home/factorio/saves/latest.zip"
create_new_world=true

if [ "$create_new_world" = true ] ; then
    /opt/factorio/bin/x64/factorio \
        --create $save_file \
        --map-gen-settings $config_dir/map-gen-settings.json \
        --map-settings $config_dir/map-settings.json
fi

systemctl daemon-reload
systemctl enable --now factorio.service
systemctl enable --now factorio-save-sync.service
