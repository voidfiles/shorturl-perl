#! /bin/bash


if [ "$1" = "provision" ]; then
  set -ax;
  ssh "root@$2" 'bash -s' < ./provision.sh;
  exit 1;
fi;

set -ax;
apt-get update;
apt-get install nginx supervisor build-essential curl;

touch /etc/nginx/sites-enabled/shorturl;
rm /etc/nginx/sites-enabled/default;

cat <<InputComesFromHERE > /etc/nginx/sites-enabled/shorturl
server {
       server_name shorturl.brntgarlic.com default_server;
       listen 80;

       location / {
          proxy_pass        http://localhost:5001;
          proxy_set_header  X-Real-IP \$remote_addr;
        }

}
InputComesFromHERE

/etc/init.d/nginx reload;

