#!/bin/bash
VERSION="1.1.110"
BUILD="headless"
DISTRO="linux64"
FACTORIO_PACKAGE_NAME="${VERSION}.tar.xz"

# Download Factorio package
curl https://www.factorio.com/get-download/${VERSION}/${BUILD}/${DISTRO} -L --output /tmp/${FACTORIO_PACKAGE_NAME}

# Extract package
cd /opt/
sudo tar -xJf /tmp/${FACTORIO_PACKAGE_NAME}

# Create Factorio system user
useradd factorio
chown -R factorio:factorio /opt/factorio

# Start Factorio binary
su factorio

# This can be removed if there is an existing saved game
/opt/factorio/bin/x64/factorio --create /opt/factorio/saves/my-save.zip

/opt/factorio/bin/x64/factorio --start-server /opt/factorio/saves/my-save.zip
