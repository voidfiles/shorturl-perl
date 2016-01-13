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
touch /etc/nginx/sites-enabled/default;
rm /etc/nginx/sites-enabled/default;

cat <<InputComesFromHERE > /etc/nginx/sites-enabled/shorturl
server {
       server_name shorturl.brntgarlic.com default_server;
       listen 80;

       location / {
          proxy_pass        http://localhost:5000;
          proxy_set_header  X-Real-IP \$remote_addr;
        }

}
InputComesFromHERE

/etc/init.d/nginx reload;

cat <<InputComesFromHERE > /etc/supervisor/conf.d/shorturl.conf

[program:shorturl]
directory=/srv/shorturl/builds/current/shorturl
command=/usr/bin/carton exec -- starman --workers 10 --port 5000 -E production --disble-keepalive
user=root
stdout_logfile=/var/log/shorturl.perl.log
stderr_logfile=/var/log/shorturl.perl.log
autostart=false
InputComesFromHERE

/usr/bin/supervisorctl reread;
/usr/bin/supervisorctl update;
/usr/bin/supervisorctl stop shorturl;
/usr/bin/supervisorctl start shorturl;

