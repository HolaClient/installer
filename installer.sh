#!/bin/bash

echo "  _    _       _        _____ _ _            _   "
echo " | |  | |     | |      / ____| (_)          | |  "
echo " | |__| | ___ | | __ _| |    | |_  ___ _ __ | |_ "
echo " |  __  |/ _ \| |/ _\` | |    | | |/ _ \ '_ \| __|"
echo " | |  | | (_) | | (_| | |____| | |  __/ | | | |_ "
echo " |_|  |_|\___/|_|\__,_|\_____|_|_|\___|_| |_|\__|"
echo ""
echo ""
echo -e "${WHITE}=====================SOCIAL======================"
echo -e "${GRAY}[+] ${WHITE}[${CYAN}Discord${WHITE}] ${WHITE}https://discord.gg/CvqRH9TrYK "
echo -e "${GRAY}[+] ${WHITE}[${CYAN}Github ${WHITE}] ${WHITE}https://github.com/CR072/HolaClient "
echo -e "${GRAY}[+] ${WHITE}[${CYAN}Docs   ${WHITE}] ${WHITE}https://docs.holaclient.tech/"
echo -e "${WHITE}================================================="

echo "Please choose an option:"
echo "1. Install HolaClient"
echo "2. Update HolaClient"
echo "3. Install Dependencies"
echo "4. Uninstall HolaClient"

read -p "Enter your choice (1-4): " choice

if [[ $choice == "1" ]]; then
  echo "Installing HolaClient..."
  read -p "Enter the HolaClient version to clone: " version
  read -p "Silent install? (true/false): " silent

  mkdir /var/www/holaclient
  cd /var/www/holaclient
  sudo apt -y update && sudo apt -y upgrade
  sudo apt -y install git
  git clone https://github.com/CR072/HolaClient
  sudo apt -y update && sudo apt -y upgrade

  curl -sL https://deb.nodesource.com/setup_17.x | sudo bash -
  sudo apt-get install -y nodejs gcc g++ make
  node -v
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt-get update && sudo apt-get install yarn

  cd HolaClient
  npm i
  npm i -g pm2

  if [[ $silent == "true" ]]; then
    pm2 start index.js --name "holaclient" --silent
  else
    pm2 start index.js --name "holaclient"
  fi

  sudo apt install -y python3-certbot-nginx nginx
  ufw allow 80 && ufw allow 443
  rm /etc/nginx/sites-enabled/default

  read -p "Enter your domain: " domain
  read -p "Enter the port: " port

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
    proxy_pass "http://localhost:$port/afkwspath";
  }

  server_name $domain;
  ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
  ssl_session_cache shared:SSL:10m;
  ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers HIGH:!aNULL:!MD5;
  ssl_prefer_server_ciphers on;

  location / {
    proxy_pass http://localhost:$port/;
    proxy_buffering off;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
EOL

  sudo systemctl restart nginx

  echo "HolaClient installation completed successfully."

elif [[ $choice == "2" ]]; then
  echo "Updating HolaClient..."
  cd /var/www/holaclient/HolaClient
  git pull
  npm i
  echo "HolaClient update completed successfully."

elif [[ $choice == "3" ]]; then
  echo "Installing dependencies..."
  cd /var/www/holaclient/HolaClient
  npm i
  echo "Dependencies installation completed successfully."

elif [[ $choice == "4" ]]; then
  echo "Uninstalling HolaClient..."
  cd /var/www/holaclient/HolaClient
  npm uninstall
  echo "HolaClient uninstallation completed successfully."

else
  echo "Invalid choice. Exiting..."
  exit 1

fi
