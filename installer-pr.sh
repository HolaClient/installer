#!/bin/bash

RED="\033[0;31m"
WHITE='\033[1;37m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
    echo -e "• [${RED}ERROR${NC}] Installer must be initiated with sudo privileges!"
    exit 1
fi

clear
echo -e "${WHITE}"
echo -e "  _    _       _        _____ _ _            _   "
echo -e " | |  | |     | |      / ____| (_)          | |  "
echo -e " | |__| | ___ | | __ _| |    | |_  ___ _ __ | |_ "
echo -e " |  __  |/ _ \| |/ _\` | |    | | |/ _ \ '_ \| __|"
echo -e " | |  | | (_) | | (_| | |____| | |  __/ | | | |_ "
echo -e " |_|  |_|\___/|_|\__,_|\_____|_|_|\___|_| |_|\__|"
echo -e "${NC}"
echo -e "#################################################"
echo -e "# HolaClient Installation script @ v1.0"
echo -e "# "
echo -e "# https://holaclient.tech"
echo -e "# https://github.com/HolaClient"
echo -e "# https://discord.gg/CvqRH9TrYK"
echo -e "# "
echo -e "# Running $(lsb_release -is) version $(lsb_release -rs)"
echo -e "#################################################"
echo -e "${NC}"
echo -e "What would you like to do?"
echo -e "• [0] Install HolaClient and configure Nginx with SSL"
echo -e "• [1] Install HolaClient"
echo -e "• [2] Update HolaClient"
echo -e "• [3] Install Dependencies"
echo -e "• [4] Configure Nginx with SSL"
echo -e "• [5] Uninstall HolaClient"

read -p "Enter your choice (0-5): " choice
echo -e "${NC}"
if [[ $choice == "0" ]]; then
    if [[ -d "/var/www/HolaClient" ]]; then
        echo -e "• [${RED}ERROR${NC}] HolaClient is already installed! Please select option 5 to reinstall it."
        exit 1
    fi
    
    read -p "Enter the HolaClient version to install (latest): " version
    version=${version:-latest}
    read -p "Enter your domain (client.example.com): " domain
    read -p "Enter the port (2000): " port
    port=${port:-2000}
    read -p "Enter your email (admin@example.com): " email
    email=${email:-support@holaclient.tech}
    echo -e "${NC}"
    echo -e "#################################################"
    echo -e "# HolaClient Installation Config"
    echo -e "# "
    echo -e "# Domain: $domain"
    echo -e "# Port: $port"
    echo -e "# Email: $email"
    echo -e "# Version: $version"
    echo -e "# "
    echo -e "#################################################"
    echo -e "${NC}"
    read -p "Are the above details correct? (y/n): " confirm
    if [[ $confirm == "y" ]]; then
        sudo mkdir -p /var/www/
        cd /var/www/
        echo -e ""
        echo -e "• [${CYAN}HC Installer${NC}] Updating system..."
        sudo apt -y update > /dev/null 2>&1 && sudo apt -y upgrade > /dev/null 2>&1
        echo -e "• [${CYAN}HC Installer${NC}] Installing Git..."
        sudo apt -y install git > /dev/null 2>&1
        echo -e "• [${CYAN}HC Installer${NC}] Installing NodeJS v20..."
        sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash > /dev/null 2>&1
        source ~/.nvm/nvm.sh > /dev/null 2>&1
        nvm install 20 && nvm use 20 > /dev/null 2>&1
        sudo apt-get install tee -y > /dev/null 2>&1
        echo -e "• [${CYAN}HC Installer${NC}] Installing dependencies..."
        sudo apt-get install -y gcc g++ make > /dev/null 2>&1
        curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - > /dev/null 2>&1
        echo -e "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list > /dev/null 2>&1
        sudo apt-get update > /dev/null 2>&1 && sudo apt-get install yarn -y > /dev/null 2>&1
        echo -e "• [${CYAN}HC Installer${NC}] Downloading HolaClient files..."
        git clone --quiet --single-branch --branch "$version" https://github.com/HolaClient/HolaClient
        cd HolaClient
        echo -e "Installing Packages..."
        npm i > /dev/null 2>&1
        npm i -g pm2 > /dev/null 2>&1
        pm2 start index.js --name "holaclient" > /dev/null 2>&1
        echo -e "• [${CYAN}HC Installer${NC}] HolaClient installation completed successfully."
        echo -e "• [${CYAN}HC Configurator${NC}] Configuring Nginx..."
        sudo apt install -y python3-certbot-nginx nginx > /dev/null 2>&1
        ufw allow 80 > /dev/null && ufw allow 443 > /dev/null
        certbot certonly --nginx -d "$domain" -m "$email"
    sudo tee /etc/nginx/sites-enabled/holaclient.conf > /dev/null << EOL
server {
  listen 80;
  server_name $domain;
  return 301 https://\$server_name\$request_uri;
}

server {
  listen 443 ssl http2;

  location /afkwspath {
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_pass "http://$domain:$port/afkwspath";
  }

  server_name $domain;
  ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
  ssl_session_cache shared:SSL:10m;
  ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers HIGH:!aNULL:!MD5;
  ssl_prefer_server_ciphers on;

  location / {
    proxy_pass http://$domain:$port/;
    proxy_buffering off;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
EOL
        sudo systemctl restart nginx
        echo -e "• [${CYAN}HC Configurator${NC}] Nginx configuration with SSL completed successfully."
    else
        echo -e "• [${CYAN}HCI Manager${NC}] Incorrect configuration, script has been terminated successfully!"
        exit 1
    fi
    elif [[ $choice == "1" ]]; then
    if [[ -d "/var/www/HolaClient" ]]; then
        echo -e "HolaClient is already installed! Please select option 5 to reinstall it."
        exit 1
    fi
    
    read -p "Enter the HolaClient version to install (latest): " version
    version=${version:-latest}
    
    cd /var/www/
    echo -e ""
    echo -e "Updating system..."
    sudo apt -y update > /dev/null 2>&1 && sudo apt -y upgrade > /dev/null 2>&1
    echo -e "Installing Git..."
    sudo apt -y install git > /dev/null 2>&1
    echo -e "Installing NodeJS..."
    sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash > /dev/null 2>&1
    source ~/.nvm/nvm.sh > /dev/null 2>&1
    nvm install 20 && nvm use 20 > /dev/null 2>&1
    sudo apt-get install tee -y > /dev/null 2>&1
    echo -e "Installing dependencies..."
    sudo apt-get install -y gcc g++ make > /dev/null 2>&1
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - > /dev/null 2>&1
    echo -e "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list > /dev/null 2>&1
    sudo apt-get update > /dev/null 2>&1 && sudo apt-get install yarn -y > /dev/null 2>&1
    echo -e "Downloading HolaClient files..."
    git clone --quiet --single-branch --branch "$version" https://github.com/HolaClient/HolaClient
    cd HolaClient
    echo -e "Installing Packages..."
    npm i > /dev/null 2>&1
    npm i -g pm2 > /dev/null 2>&1
    pm2 start index.js --name "holaclient" > /dev/null 2>&1
    echo -e "HolaClient installation completed successfully."
    
    elif [[ $choice == "2" ]]; then
    if [ ! -d "/var/www/HolaClient" ]; then
        echo -e "HolaClient is not installed, please Install it first!"
        exit 1
    fi
    
    echo -e "Checking for updates in HolaClient..."
    cd /var/www/HolaClient
    latest_commit_github=$(git ls-remote https://github.com/HolaClient/HolaClient.git HEAD | cut -f 1)
    current_commit_local=$(git rev-parse HEAD)
    if [[ $latest_commit_github != $current_commit_local ]]; then
        backup_dir="/var/www/HolaClient_backup_$(date +'%Y%m%d%H%M%S')"
        echo -e "Updates found! Taking a backup of the current directory to $backup_dir..."
        cp -r /var/www/HolaClient "$backup_dir"
        echo -e "Updating HolaClient..."
        git fetch origin
        git pull origin latest
        echo -e "HolaClient update completed successfully."
    else
        echo -e "HolaClient is already up to date."
    fi
    
    elif [[ $choice == "3" ]]; then
    echo -e "Installing dependencies..."
    cd /var/www/HolaClient
    echo -e "Updating system..."
    sudo apt -y update > /dev/null 2>&1 && sudo apt -y upgrade > /dev/null 2>&1
    echo -e "Installing Git..."
    sudo apt -y install git > /dev/null 2>&1
    echo -e "Installing NodeJS..."
    sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash > /dev/null 2>&1
    source ~/.nvm/nvm.sh > /dev/null 2>&1
    nvm install 20 && nvm use 20 > /dev/null 2>&1
    sudo apt-get install tee -y > /dev/null 2>&1
    echo -e "Installing dependencies..."
    sudo apt-get install -y gcc g++ make > /dev/null 2>&1
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - > /dev/null 2>&1
    echo -e "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list > /dev/null 2>&1
    sudo apt-get update > /dev/null 2>&1 && sudo apt-get install yarn -y > /dev/null 2>&1
    echo -e "Dependencies installation completed successfully."
    
    elif [[ $choice == "4" ]]; then
    read -p "Enter your domain (client.example.com): " domain
    read -p "Enter the port (2000): " port
    port=${port:-2000}
    read -p "Enter your email (admin@example.com): " email
    email=${email:-support@holaclient.tech}
    sudo apt install -y python3-certbot-nginx nginx > /dev/null 2>&1
    ufw allow 80 > /dev/null && ufw allow 443 > /dev/null
    certbot certonly --nginx -d "$domain" -m "$email"
    sudo tee /etc/nginx/sites-enabled/holaclient.conf > /dev/null << EOL
server {
  listen 80;
  server_name $domain;
  return 301 https://\$server_name\$request_uri;
}

server {
  listen 443 ssl http2;

  location /afkwspath {
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_pass "http://$domain:$port/afkwspath";
  }

  server_name $domain;
  ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
  ssl_session_cache shared:SSL:10m;
  ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers HIGH:!aNULL:!MD5;
  ssl_prefer_server_ciphers on;

  location / {
    proxy_pass http://$domain:$port/;
    proxy_buffering off;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
EOL
    sudo systemctl restart nginx
    echo -e "Nginx configuration with SSL completed successfully."
    
    elif [[ $choice == "5" ]]; then
    if [ ! -d "/var/www/HolaClient" ]; then
        echo -e "HolaClient is not installed, please Install it first!"
        exit 1
    fi
    read -p "Are you sure you want to uninstall HolaClient? This will delete all HolaClient files and configurations. (y/n): " confirm
    if [[ $confirm == "y" ]]; then
        echo -e "Uninstalling HolaClient..."
        rm -r /var/www/HolaClient/node_modules
        if [ ! -d "/etc/HolaClientBackups" ]; then
            mkdir /etc/HolaClientBackups
        fi
        mkdir /etc/HolaClientBackups/$(date +'%Y%m%d%H%M')
        mv /var/www/HolaClient /etc/HolaClientBackups/$(date +'%Y%m%d%H%M')
        rm /etc/nginx/sites-enabled/holaclient.conf
        pm2 delete holaclient > /dev/null
        echo -e "HolaClient uninstallation completed successfully."
    else
        echo -e "Uninstallation canceled."
    fi
else
    echo -e "Invalid choice. Exiting..."
    exit 1
fi
