#!/bin/bash

#---------------------------
#-------configuration-------
#---------------------------

echo ''
echo '----------------------- URL ДОМЕНА -------------------------------'
AGAIN=yes
while [ "$AGAIN" = "yes" ]
do
if [ $1 ]; then
DOMAIN=${1}
echo ${DOMAIN}
else
read DOMAIN
fi
if [ ${DOMAIN} ]; then
AGAIN=no
else
echo 'WARNING: URL домена не может быть пустым.'
fi
done
echo '--------------------- НАЗВАНИЕ ТЕМЫ ------------------------------'
if [ $2 ]; then
THEME=${2}
echo ${THEME}
else
read THEME
THEME=${THEME:='skeleton'}
fi
echo '-------------- ПАРОЛЬ ОТ АДМИН-ПАНЕЛИ И FTP ----------------------'
AGAIN=yes
while [ "$AGAIN" = "yes" ]
do
if [ $3 ]; then
PASSWD=${3}
echo ${PASSWD}
else
read PASSWD
fi
if [ ${PASSWD} ]
then
AGAIN=no
else
echo 'WARNING: Пароль от админ-панели и FTP не может быть пустым.'
fi
done
echo '------------------------------------------------------------------'
echo ''

sleep 3

echo '---------------------'
echo '-------update--------'
echo '---------------------'
apt-get -y -qq update && apt-get -y -qq install debian-keyring debian-archive-keyring wget curl nano htop sudo lsb-release ca-certificates git-core openssl netcat
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
apt-get -y -qq update && apt-get -y -qq upgrade
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
OPENSSL=`echo "${PASSWD}" | openssl passwd -1 -stdin -salt cinemapress`
rm -rf /home/${DOMAIN}/.??*
git clone https://github.com/CinemaPress/CinemaPress-CMS.git /home/${DOMAIN}
chown -R ${DOMAIN}:www-data /home/${DOMAIN}/
echo 'OK'
echo '---------------------'
echo '--------nginx--------'
echo '---------------------'
AGAIN=yes
DEFAULT_PORT=3333
BACKUP_PORT=3334
while [ "$AGAIN" = "yes" ]
do
DEFAULT_PORT_TEST=`netstat -tunlp | grep ${DEFAULT_PORT}`
BACKUP_PORT_TEST=`netstat -tunlp | grep ${BACKUP_PORT}`
if [ "$DEFAULT_PORT_TEST" = "" ] && [ "$BACKUP_PORT_TEST" = "" ]
then
AGAIN=no
else
DEFAULT_PORT=$((DEFAULT_PORT+1))
BACKUP_PORT=$((BACKUP_PORT+1))
fi
done
rm -rf /etc/nginx/conf.d/rewrite.conf
ln -s /home/${DOMAIN}/config/rewrite.conf /etc/nginx/conf.d/rewrite.conf
rm -rf /etc/nginx/conf.d/${DOMAIN}.conf
ln -s /home/${DOMAIN}/config/nginx.conf /etc/nginx/conf.d/${DOMAIN}.conf
sed -i "s/DEFAULT_PORT/${DEFAULT_PORT}/g" /home/${DOMAIN}/config/nginx.conf
sed -i "s/BACKUP_PORT/${BACKUP_PORT}/g" /home/${DOMAIN}/config/nginx.conf
sed -i "s/example.com/${DOMAIN}/g" /home/${DOMAIN}/config/nginx.conf
sed -i "s/user  nginx;/user  www-data;/g" /etc/nginx/nginx.conf
sed -i "s/server_names_hash_bucket_size 64;//g" /etc/nginx/nginx.conf
sed -i "s/http {/http {\n    server_names_hash_bucket_size 64;/g" /etc/nginx/nginx.conf
sed -i "s/#gzip/gzip/g" /etc/nginx/nginx.conf
echo "${DOMAIN}:$OPENSSL" >> /etc/nginx/nginx_pass
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
echo ${PASSWD} | ftpasswd --stdin --passwd --file=/etc/proftpd/ftpd.passwd --name=${DOMAIN} --shell=/bin/false --home=/home/${DOMAIN} --uid=${USERID} --gid=${USERID}
echo 'OK'
echo '---------------------'
echo '------memcached------'
echo '---------------------'
AGAIN=yes
MEMCACHED_PORT=11212
while [ "$AGAIN" = "yes" ]
do
MEMCACHED_PORT_TEST=`netstat -tunlp | grep ${MEMCACHED_PORT}`
if [ "$MEMCACHED_PORT_TEST" = "" ]
then
AGAIN=no
else
MEMCACHED_PORT=$((MEMCACHED_PORT+1))
fi
done
rm -rf /etc/memcached_${DOMAIN}.conf
cp /etc/memcached.conf /etc/memcached_${DOMAIN}.conf
sed -i "s/11211/${MEMCACHED_PORT}/g" /etc/memcached_${DOMAIN}.conf
echo 'OK'
echo '---------------------'
echo '-------config--------'
echo '---------------------'
if [ "$THEME" != "skeleton" ]; then
git clone https://github.com/CinemaPress/Theme-${THEME}.git /home/${DOMAIN}/themes/${THEME}
chown -R ${DOMAIN}:www-data /home/${DOMAIN}/themes
sed -i "s/\"theme\":\s*\".*\"/\"theme\":\"${THEME}\"/" /home/${DOMAIN}/config/config.js
fi
sed -i "s/example.com/${DOMAIN}/g" /home/${DOMAIN}/config/config.js
sed -i "s/11211/${MEMCACHED_PORT}/" /home/${DOMAIN}/config/config.js
cp /home/${DOMAIN}/config/config.js /home/${DOMAIN}/config/config.old.js
echo 'OK'
echo '---------------------'
echo '--------cron---------'
echo '---------------------'
echo "@reboot root cd /home/${DOMAIN}/ && PORT=${DEFAULT_PORT} forever start --minUptime 1000ms --spinSleepTime 1000ms --append --uid \"${DOMAIN}-default\" --killSignal=SIGTERM -c \"nodemon --delay 2 --exitcrash\" app.js >> /home/${DOMAIN}/config/autostart.log 2>&1" >> /etc/crontab
echo "@reboot root cd /home/${DOMAIN}/ && PORT=${BACKUP_PORT} forever start --minUptime 1000ms --spinSleepTime 1000ms --append --uid \"${DOMAIN}-backup\" app.js >> /home/${DOMAIN}/config/autostart.log 2>&1" >> /etc/crontab
echo "@hourly root forever restart ${DOMAIN}-backup >> /home/${DOMAIN}/config/autostart.log 2>&1" >> /etc/crontab
echo 'OK'
echo '---------------------'
echo '-------sysctl--------'
echo '---------------------'
mv /etc/sysctl.conf /etc/sysctl.old.conf
cp /home/${DOMAIN}/config/sysctl.conf /etc/sysctl.conf
sysctl -p
echo 'OK'
echo '---------------------'
echo '-------restart-------'
echo '---------------------'
service nginx restart
service proftpd restart
service memcached restart
echo '---------------------'
echo '--------start--------'
echo '---------------------'
cd /home/${DOMAIN}/
npm install --loglevel=silent --parseable
npm install --loglevel=silent --parseable forever -g
npm install --loglevel=silent --parseable nodemon -g
indexer --all || indexer --all --rotate
echo 'OK'
echo '-----------------------------------------------------------------'
echo '-----------------------------------------------------------------'
echo '-----                                                       -----'
echo '-----         УРА! CinemaPress CMS готова к работе!         -----'
echo '-----     Чтобы все заработало, требуется перезагрузка.     -----'
echo '-----       Сервер будет перезагружен через 10 сек ...      -----'
echo '-----                                                       -----'
echo '-----------------------------------------------------------------'
echo '-----------------------------------------------------------------'
echo '-----                                                       -----'
echo '!!!!!     Нажмите CTRL+C ^C чтобы отменить перезагрузку     !!!!!'
echo '-----                                                       -----'
echo '-----------------------------------------------------------------'
echo '-----------------------------------------------------------------'
sleep 10
reboot