#!/bin/bash
sudo apt update # update apt cache
sudo apt install curl nginx
sudo apt-get install certbot python3-certbot-nginx

read -e -p 'Funkwhale Version: ' -i "1.4.0" FUNKWHALE_VERSION
read -p 'Funkwhale Hostname: ' FUNKWHALE_HOSTNAME
read -e -p 'Funkwhale Protocol: (http/https)' -i "http" FUNKWHALE_PROTOCOL
read -e -p 'Funkwhale Max File Upload Size: ' -i "100M" NGINX_MAX_BODY_SIZE
DJANGO=$(openssl rand -base64 45)
echo "Variables set, Django secret = $DJANGO"

curl -L -o docker-compose.yml "https://dev.funkwhale.audio/funkwhale/funkwhale/raw/${FUNKWHALE_VERSION}/deploy/docker-compose.yml"
curl -L -o .env "https://dev.funkwhale.audio/funkwhale/funkwhale/raw/${FUNKWHALE_VERSION}/deploy/env.prod.sample"
curl -L -o funkwhale_proxy.conf "https://dev.funkwhale.audio/funkwhale/funkwhale/raw/$FUNKWHALE_VERSION/deploy/funkwhale_proxy.conf" && echo true || exit
curl -L -o funkwhale.template "https://dev.funkwhale.audio/funkwhale/funkwhale/raw/$FUNKWHALE_VERSION/deploy/docker.proxy.template"

echo  "download ok, setting .env variables"

chmod 600 .env
sed -i "s/FUNKWHALE_VERSION=latest/FUNKWHALE_VERSION=$FUNKWHALE_VERSION/" .env
# SET DJANGO SECRET
sed -i "s/FUNKWHALE_PROTOCOL=https/FUNKWHALE_PROTOCOL=$UNKWHALE_PROTOCOL/" .env
sed -i "s/FUNKWHALE_HOSTNAME=yourdomain.funkwhale/FUNKWHALE_HOSTNAME=$FUNKWHALE_HOSTNAME/" .env
sed -i "s/NGINX_MAX_BODY_SIZE=100M/NGINX_MAX_BODY_SIZE=$NGINX_MAX_BODY_SIZE/" .env

echo "variables set, building, migrating and creating superuser"

sudo docker compose pull
sudo docker compose up -d postgres
sudo docker compose run --rm api funkwhale-manage migrate
sudo docker compose run --rm api funkwhale-manage fw users create --superuser

echo "finished funkwhale setup. Starting containers"

sudo docker compose up -d

echo "Setting up reverse proxy"

ln -s funkwhale_proxy.conf /etc/nginx/funkwhale_proxy.conf
ln -s funkwhale.template /etc/nginx/sites-available/funkwhale.template
set -a && source .env && set +a
envsubst "`env | awk -F = '{printf \" $%s\", $$1}'`" \
   < funkwhale.template \
   > funkwhale.conf
ln -s /etc/nginx/sites-available/funkwhale.conf /etc/nginx/sites-enabled/



if [$FUNKWHALE_PROTOCOL = 'http']; then
   # COMMENT OUT TLS
   sudo systemctl reload nginx
else if [$FUNKWHALE_PROTOCOL = 'https']; then
   sudo systemctl reload nginx
   sudo certbot --nginx -d $FUNKWHALE_HOSTNAME
fi

echo "Reverseproxy setup, all done!"