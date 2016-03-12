#!/bin/bash

#---------------------------
#-------configuration-------
#---------------------------

echo ''
echo '---------------------- DOMAIN URL --------------------------------'
if [ $1 ]; then
DOMAIN=${1}
echo ${DOMAIN}
else
read DOMAIN
fi
if ! [ ${DOMAIN} ]; then
echo 'ERROR: URL домена не может быть пустым.'
exit
fi
echo '------------------------ THEME -----------------------------------'
if [ $2 ]; then
THEME=${2}
echo ${THEME}
else
read THEME
THEME=${THEME:='skeleton'}
fi
echo '------------------------------------------------------------------'
echo ''

sleep 3

#---------------------------
#---------------------------

echo '---------------------'
echo '-------update--------'
echo '---------------------'
apt-get -y update && apt-get -y install wget curl nano htop sudo lsb-release ca-certificates git-core
VER=`lsb_release -cs`
echo 'OK'
echo '---------------------'
echo '-------sources-------'
echo '---------------------'
echo "deb http://httpredir.debian.org/debian ${VER} main contrib non-free \n deb-src http://httpredir.debian.org/debian ${VER} main contrib non-free \n deb http://httpredir.debian.org/debian ${VER}-updates main contrib non-free \n deb-src http://httpredir.debian.org/debian ${VER}-updates main contrib non-free \n deb http://security.debian.org/ ${VER}/updates main contrib non-free \n deb-src http://security.debian.org/ ${VER}/updates main contrib non-free \n deb http://nginx.org/packages/debian/ ${VER} nginx \n deb-src http://nginx.org/packages/debian/ ${VER} nginx \n deb http://mirror.de.leaseweb.net/dotdeb/ ${VER} all \n deb-src http://mirror.de.leaseweb.net/dotdeb/ ${VER} all" > /etc/apt/sources.list
echo 'OK'
echo '---------------------'
echo '---------key---------'
echo '---------------------'
wget --no-check-certificate http://www.dotdeb.org/dotdeb.gpg; apt-key add dotdeb.gpg; wget --no-check-certificate http://nginx.org/keys/nginx_signing.key; apt-key add nginx_signing.key
rm -rf dotdeb.gpg
rm -rf nginx_signing.key
echo 'OK'
echo '---------------------'
echo '-------upgrade-------'
echo '---------------------'
apt-get -y update && apt-get -y upgrade
echo 'OK'
echo '---------------------'
echo '-------install-------'
echo '---------------------'
wget -qO- https://deb.nodesource.com/setup_5.x | bash -
apt-get -y install nginx proftpd-basic openssl mysql-client nodejs memcached libltdl7 libodbc1 libpq5
echo 'OK'
echo '---------------------'
echo '--------user---------'
echo '---------------------'
useradd ${DOMAIN} -m -U -s /bin/false
rm -rf /home/${DOMAIN}/.??*
git clone https://github.com/CinemaPress/CinemaPress-CMS.git /home/${DOMAIN}
chown -R ${DOMAIN}:www-data /home/${DOMAIN}/
echo 'OK'
echo '---------------------'
echo '--------admin--------'
echo '---------------------'
echo 'Придумайте пароль для админ-панели:'
echo '---------------------'
OPENSSL=`openssl passwd`
echo "${DOMAIN}:$OPENSSL" >> /etc/nginx/nginx_pass
echo '---------------------'
echo '--------nginx--------'
echo '---------------------'
rm -rf /etc/nginx/conf.d/rewrite.conf
ln -s /home/${DOMAIN}/config/rewrite.conf /etc/nginx/conf.d/rewrite.conf
rm -rf /etc/nginx/conf.d/upstream.conf
ln -s /home/${DOMAIN}/config/upstream.conf /etc/nginx/conf.d/upstream.conf
rm -rf /etc/nginx/conf.d/${DOMAIN}.conf
ln -s /home/${DOMAIN}/config/nginx.conf /etc/nginx/conf.d/${DOMAIN}.conf
sed -i "s/example.com/${DOMAIN}/g" /home/${DOMAIN}/config/nginx.conf
sed -i "s/user  nginx;/user  www-data;/g" /etc/nginx/nginx.conf
sed -i "s/server_names_hash_bucket_size 64;//g" /etc/nginx/nginx.conf
sed -i "s/http {/http {\n    server_names_hash_bucket_size 64;/g" /etc/nginx/nginx.conf
sed -i "s/#gzip/gzip/g" /etc/nginx/nginx.conf
echo 'OK'
echo '---------------------'
echo '-------config--------'
echo '---------------------'
if [ "$THEME" != "skeleton" ]; then
git clone https://github.com/CinemaPress/Theme-${THEME}.git /home/${DOMAIN}/themes/${THEME}
sed -i "s/\"theme\":\s*\".*\"/\"theme\":\"${THEME}\"/" /home/${DOMAIN}/config/config.js
fi
sed -i "s/example.com/${DOMAIN}/g" /home/${DOMAIN}/config/config.js
echo 'OK'
echo '---------------------'
echo '-------sphinx--------'
echo '---------------------'
wget --no-check-certificate http://sphinxsearch.com/files/sphinxsearch_2.2.10-release-1~${VER}_amd64.deb && dpkg -i sphinxsearch* && rm -rf sphinxsearch_2.2.10-release-1~${VER}_amd64.deb
rm -rf /etc/sphinxsearch/sphinx.conf
ln -s /home/${DOMAIN}/config/sphinx.conf /etc/sphinxsearch/sphinx.conf
sed -i "s/example.com/${DOMAIN}/g" /home/${DOMAIN}/config/sphinx.conf
echo 'OK'
echo '---------------------'
echo '------proftpd--------'
echo '---------------------'
echo 'AuthUserFile    /etc/proftpd/ftpd.passwd' >> /etc/proftpd/proftpd.conf
echo '/bin/false' >> /etc/shells
sed -i "s/# DefaultRoot/DefaultRoot/g" /etc/proftpd/proftpd.conf
echo 'OK'
echo '---------------------'
echo '---------ftp---------'
echo '---------------------'
USERID=`id -u ${DOMAIN}`
ftpasswd --passwd --file=/etc/proftpd/ftpd.passwd --name=${DOMAIN} --shell=/bin/false --home=/home/${DOMAIN} --uid=${USERID} --gid=${USERID}
echo 'OK'
echo '---------------------'
echo '--------cron---------'
echo '---------------------'
echo "@reboot root cd /home/${DOMAIN}/ && PORT=3333 npm start >> /home/${DOMAIN}/config/autostart.log 2>&1" >> /etc/crontab
echo "@reboot root cd /home/${DOMAIN}/ && PORT=3334 forever start --uid=\"cinemapress\" app.js >> /home/${DOMAIN}/config/autostart.log 2>&1" >> /etc/crontab
echo "@hourly root forever restart cinemapress >> /home/${DOMAIN}/config/autostart.log 2>&1" >> /etc/crontab
echo 'OK'
echo '---------------------'
echo '-------restart-------'
echo '---------------------'
service nginx restart
service proftpd restart
service memcached restart
echo "flush_all" | nc -q 2 localhost 11211
echo 'OK'
echo '---------------------'
echo '--------start--------'
echo '---------------------'
cd /home/${DOMAIN}/
npm install
npm install forever -g
npm install nodemon -g
indexer --all || indexer --all --rotate
npm start
echo 'OK'
echo '-------------------------------------'
echo 'УРА! CinemaPress CMS готова к работе!'
echo 'Сервер будет перезагружен через 5 сек'
echo '-------------------------------------'
echo "Админ панель сайта: http://${DOMAIN}/admin"
sleep 5
reboot