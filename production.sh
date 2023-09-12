#!/bin/bash
# HolaClient Installation Script
#
# Server Files: /mnt/server

echo -e "Starting Installation Of HolaClient!"
echo -e "Installing packages..."

apt update > /dev/null
apt install -y git curl jq file unzip make gcc g++ python python-dev libtool wget > /dev/null

echo -e "Creating server files..."
mkdir -p /mnt/server
cd /mnt/server

if [ "$(ls -A /mnt/server)" ]; then
    echo -e "⚠ Warning: The /mnt/server directory is not empty."
    echo -e "To prevent issues, this script has been automatically halted."
    echo -e "To update the current HolaClient version, please refer to our docs!"
    echo -e "  _    _       _        _____ _ _            _   "
    echo -e " | |  | |     | |      / ____| (_)          | |  "
    echo -e " | |__| | ___ | | __ _| |    | |_  ___ _ __ | |_ "
    echo -e " |  __  |/ _ \| |/ _\` | |    | | |/ _ \ '_ \| __|"
    echo -e " | |  | | (_) | | (_| | |____| | |  __/ | | | |_ "
    echo -e " |_|  |_|\___/|_|\__,_|\_____|_|_|\___|_| |_|\__|"
    echo -e ""
    echo -e "=====================SOCIAL======================"
    echo -e "[+] [Discord]  https://discord.gg/CvqRH9TrYK "
    echo -e "[+] [GitHub]  https://github.com/CR072/HolaClient "
    echo -e "[+] [HolaSMP]  https://discord.gg/Dms5dsmVAs "
    echo -e "================================================="
    exit 10
else
    echo -e "✔ /mnt/server is empty."
    echo -e "Downloading the files..."
    git clone --single-branch --branch ${VERSION} https://github.com/CR072/HolaClient .
    echo -e "✔ Successfully downloaded HolaClient!"
fi

echo "Installing additional Node.JS packages..."

if [[ ! -z ${NODE_PACKAGES} ]]; then
    /usr/local/bin/npm install ${NODE_PACKAGES} --silent
fi

echo "Installing required Node.JS packages..."

if [ -f /mnt/server/package.json ]; then
    /usr/local/bin/npm install --production --silent
fi

echo -e "✔ Successfully installed required and additional Node.JS packages!"
echo -e "✔ Successfully installed HolaClient!"
echo -e ""
echo -e "=====================SOCIAL======================"
echo -e "[+] [Discord]  https://discord.gg/CvqRH9TrYK "
echo -e "[+] [GitHub]  https://github.com/CR072/HolaClient "
echo -e "[+] [HolaSMP]  https://discord.gg/Dms5dsmVAs "
echo -e "================================================="

exit 0
