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
echo ""

echo "Please choose an option:"
echo "1. Install HolaClient"
echo "2. Update HolaClient"
echo "3. Install Dependencies"
echo "4. Uninstall HolaClient"

read -p "Enter your choice (1-4): " choice
read -p "Enter your domain: " domain
read -p "Enter the port: " port

if [[ $choice == "1" ]]; then
  read -p "Enter the HolaClient version to clone (latest): " version

  cd /var/www/
  echo "Downloading environmental dependencies..."
      sudo apt -y update --silent && sudo apt -y upgrade --silent
      sudo apt -y install git --silent
      echo "Downloading HolaClient files..."
      git clone --quiet --single-branch --branch $version https://github.com/CR072/HolaClient
      echo "Updating environmental dependencies..."
      curl -sL https://deb.nodesource.com/setup_18.x | sudo bash - --silent
      sudo apt-get install -y nodejs gcc g++ make --silent
      curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - --silent
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list --silent
      sudo apt-get update && sudo apt-get install yarn --silent
 echo ""
  cd HolaClient
  echo "Downloading HolaClient dependencies..."
  npm i
  npm i -g pm2

    pm2 start index.js --name "holaclient" --silent
    sudo apt install -y python3-certbot-nginx nginx --silent
    ufw allow 80 --silent && ufw allow 443 --silent
    certbot certonly --nginx -d $domain
    rm /etc/nginx/sites-enabled/default


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
  cd /var/www/HolaClient
  git pull
  npm i
  echo "HolaClient update completed successfully."

elif [[ $choice == "3" ]]; then
  echo "Installing dependencies..."
  cd /var/www/HolaClient
  npm i
  echo "Dependencies installation completed successfully."

elif [[ $choice == "4" ]]; then
  echo "Uninstalling HolaClient..."
  cd /var/www/HolaClient
  npm uninstall
  rm /etc/nginx/sites-enabled/holaclient.conf
  echo "HolaClient uninstallation completed successfully."

else
  echo "Invalid choice. Exiting..."
  exit 1

fi
