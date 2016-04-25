#!/bin/bash

echo '------------------------------------------------------------------'
echo '   _______ _                         ______                       '
echo '  (_______|_)                       (_____ \                      '
echo '   _       _ ____  _____ ____  _____ _____) )___ _____  ___  ___  '
echo '  | |     | |  _ \| ___ |    \(____ |  ____/ ___) ___ |/___)/___) '
echo '  | |_____| | | | | ____| | | / ___ | |   | |   | ____|___ |___ | '
echo '   \______)_|_| |_|_____)_|_|_\_____|_|   |_|   |_____|___/(___/  '
echo '                                                                  '
echo '--------------------------- URL ДОМЕНА ---------------------------'
AGAIN=yes
while [ "${AGAIN}" = "yes" ]
do
    if [ $1 ]; then
        DOMAIN=${1}
        echo ": ${DOMAIN}"
    else
        read -p ': ' DOMAIN
    fi
    if [ "${DOMAIN}" != "" ]
    then
        AGAIN=no
    else
        echo 'WARNING: URL домена не может быть пустым.'
    fi
done
echo '------------------------- НАЗВАНИЕ ТЕМЫ --------------------------'
AGAIN=yes
while [ "${AGAIN}" = "yes" ]
do
    if [ $2 ]
    then
        THEME=${2}
        echo ": ${THEME}"
    else
        read -p ': ' THEME
    fi
    if [ "${THEME}" = "" ]
    then
        AGAIN=no
        THEME='skeleton'
    else
        if [ "${THEME}" = "ted" ] || [ "${THEME}" = "barney" ] || [ "${THEME}" = "lily" ] || [ "${THEME}" = "marshall" ]
        then
            AGAIN=no
        else
            echo 'WARNING: Нет такой темы.'
        fi
    fi
done
echo '---------------- ВАШ ЛОГИН ОТ АДМИН-ПАНЕЛИ И FTP -----------------'
echo ": ${DOMAIN}"
echo '------------ ПРИДУМАЙТЕ ПАРОЛЬ ОТ АДМИН-ПАНЕЛИ И FTP -------------'
AGAIN=yes
while [ "${AGAIN}" = "yes" ]
do
    if [ $3 ]
    then
        PASSWD=${3}
        echo ": ${PASSWD}"
    else
        read -p ': ' PASSWD
    fi
    if [ "${PASSWD}" != "" ]
    then
        AGAIN=no
    else
        echo 'WARNING: Пароль от админ-панели и FTP не может быть пустым.'
    fi
done
echo '------------------------------------------------------------------'
echo ''
sleep 3
echo '------------------------------------------------------------------'
echo '-----                       ОБНОВЛЕНИЕ                       -----'
echo '------------------------------------------------------------------'
echo ''
apt-get -y -qq update && apt-get -y -qq install debian-keyring debian-archive-keyring wget curl nano htop sudo lsb-release ca-certificates git-core openssl netcat debconf-utils
VER=`lsb_release -cs`
echo "proftpd-basic shared/proftpd/inetd_or_standalone select standalone" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----            ПРОПИСЫВАЕМ СПИСОК РЕПОЗИТОРИЕВ             -----'
echo '------------------------------------------------------------------'
echo ''
echo "deb http://httpredir.debian.org/debian ${VER} main contrib non-free \n deb-src http://httpredir.debian.org/debian ${VER} main contrib non-free \n deb http://httpredir.debian.org/debian ${VER}-updates main contrib non-free \n deb-src http://httpredir.debian.org/debian ${VER}-updates main contrib non-free \n deb http://security.debian.org/ ${VER}/updates main contrib non-free \n deb-src http://security.debian.org/ ${VER}/updates main contrib non-free \n deb http://nginx.org/packages/debian/ ${VER} nginx \n deb-src http://nginx.org/packages/debian/ ${VER} nginx \n deb http://mirror.de.leaseweb.net/dotdeb/ ${VER} all \n deb-src http://mirror.de.leaseweb.net/dotdeb/ ${VER} all" > /etc/apt/sources.list
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                     ИМПОРТ КЛЮЧЕЙ                      -----'
echo '------------------------------------------------------------------'
echo ''
wget --no-check-certificate http://www.dotdeb.org/dotdeb.gpg; apt-key add dotdeb.gpg; wget --no-check-certificate http://nginx.org/keys/nginx_signing.key; apt-key add nginx_signing.key
rm -rf dotdeb.gpg
rm -rf nginx_signing.key
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                        УЛУЧШЕНИЕ                       -----'
echo '------------------------------------------------------------------'
echo ''
apt-get -y -qq update && apt-get -y -qq upgrade
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                    УСТАНОВКА ПАКЕТОВ                   -----'
echo '------------------------------------------------------------------'
echo ''
wget -qO- https://deb.nodesource.com/setup_5.x | bash -
apt-get -y install nginx proftpd-basic openssl mysql-client nodejs memcached libltdl7 libodbc1 libpq5 fail2ban iptables-persistent
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                 ДОБАВЛЕНИЕ ПОЛЬЗОВАТЕЛЯ                -----'
echo '------------------------------------------------------------------'
echo ''
useradd ${DOMAIN} -m -U -s /bin/false
OPENSSL=`echo "${PASSWD}" | openssl passwd -1 -stdin -salt cinemapress`
rm -rf /home/${DOMAIN}/*
rm -rf /home/${DOMAIN}/.??*
git clone https://github.com/CinemaPress/CinemaPress-CMS.git /home/${DOMAIN}
cp -r /home/${DOMAIN}/config/default/* /home/${DOMAIN}/config/
chown -R ${DOMAIN}:www-data /home/${DOMAIN}/
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                     НАСТРОЙКА NGINX                    -----'
echo '------------------------------------------------------------------'
echo ''
AGAIN=yes
NGINX_PORT=33333
while [ "${AGAIN}" = "yes" ]
do
    NGINX_PORT_TEST=`netstat -tunlp | grep ${NGINX_PORT}`
    if [ "${NGINX_PORT_TEST}" = "" ]
    then
        AGAIN=no
    else
        NGINX_PORT=$((NGINX_PORT+1))
    fi
done
rm -rf /etc/nginx/conf.d/rewrite.conf
mv /home/${DOMAIN}/config/rewrite.conf /etc/nginx/conf.d/rewrite.conf
rm -rf /etc/nginx/conf.d/${DOMAIN}.conf
ln -s /home/${DOMAIN}/config/nginx.conf /etc/nginx/conf.d/${DOMAIN}.conf
sed -i "s/:3000/:${NGINX_PORT}/g" /home/${DOMAIN}/config/nginx.conf
sed -i "s/example\.com/${DOMAIN}/g" /home/${DOMAIN}/config/nginx.conf
sed -i "s/user  nginx;/user  www-data;/g" /etc/nginx/nginx.conf
sed -i "s/#gzip/gzip/g" /etc/nginx/nginx.conf
echo "${DOMAIN}:$OPENSSL" >> /etc/nginx/nginx_pass
SNHBS=`grep "server_names_hash_bucket_size" /etc/nginx/nginx.conf`
if [ "${SNHBS}" = "" ]
then
    sed -i "s/http {/http {\n\n    server_names_hash_bucket_size 64;\n/g" /etc/nginx/nginx.conf
fi
LRZ=`grep "zone=cinemapress" /etc/nginx/nginx.conf`
if [ "${LRZ}" = "" ]
then
    sed -i "s/http {/http {\n\n    limit_req_zone \$binary_remote_addr zone=cinemapress:10m rate=5r\/s;\n/g" /etc/nginx/nginx.conf
fi
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                    НАСТРОЙКА SPHINX                    -----'
echo '------------------------------------------------------------------'
echo ''
I=`dpkg -s sphinxsearch | grep "Status"`
if ! [ -n "${I}" ]
then
    wget --no-check-certificate http://sphinxsearch.com/files/sphinxsearch_2.2.10-release-1~${VER}_amd64.deb -qO s.deb && dpkg -i s.deb && rm -rf s.deb
    cp /home/${DOMAIN}/config/dummy.conf /etc/sphinxsearch/sphinx.conf
fi
AGAIN=yes
SPHINX_PORT=39312
MYSQL_PORT=29306
while [ "${AGAIN}" = "yes" ]
do
    SPHINX_PORT_TEST=`netstat -tunlp | grep ${SPHINX_PORT}`
    MYSQL_PORT_TEST=`netstat -tunlp | grep ${MYSQL_PORT}`
    if [ "${SPHINX_PORT_TEST}" = "" ] && [ "${MYSQL_PORT_TEST}" = "" ]
    then
        AGAIN=no
    else
        MYSQL_PORT=$((MYSQL_PORT+1))
        SPHINX_PORT=$((SPHINX_PORT+1))
    fi
done
INDEX_DOMAIN=`echo ${DOMAIN} | sed -r "s/[^A-Za-z0-9]/_/g"`
sed -i "s/example\.com/${DOMAIN}/g" /home/${DOMAIN}/config/sphinx.conf
sed -i "s/example_com/${INDEX_DOMAIN}/g" /home/${DOMAIN}/config/sphinx.conf
sed -i "s/:9306/:${MYSQL_PORT}/g" /home/${DOMAIN}/config/sphinx.conf
sed -i "s/:9312/:${SPHINX_PORT}/g" /home/${DOMAIN}/config/sphinx.conf
CRONTAB=`grep ${DOMAIN} /etc/crontab`
if [ "${CRONTAB}" = "" ]
then
    echo "\n" >> /etc/crontab
    echo "# -----" >> /etc/crontab
    echo "# ----- ${DOMAIN} --------------------------------------------" >> /etc/crontab
    echo "# -----" >> /etc/crontab
    echo "@reboot root sleep 20 && searchd --config /home/${DOMAIN}/config/sphinx.conf >> /home/${DOMAIN}/config/autostart.log 2>&1" >> /etc/crontab
    echo "# ----- ${DOMAIN} --------------------------------------------" >> /etc/crontab
fi
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                    НАСТРОЙКА PROFTPD                   -----'
echo '------------------------------------------------------------------'
echo ''
sed -i "s/AuthUserFile    \/etc\/proftpd\/ftpd\.passwd//g" /etc/proftpd/proftpd.conf
echo 'AuthUserFile    /etc/proftpd/ftpd.passwd' >> /etc/proftpd/proftpd.conf
sed -i "s/\/bin\/false//g" /etc/shells
echo '/bin/false' >> /etc/shells
sed -i "s/# DefaultRoot/DefaultRoot/g" /etc/proftpd/proftpd.conf
USERID=`id -u ${DOMAIN}`
echo ${PASSWD} | ftpasswd --stdin --passwd --file=/etc/proftpd/ftpd.passwd --name=${DOMAIN} --shell=/bin/false --home=/home/${DOMAIN} --uid=${USERID} --gid=${USERID}
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                   НАСТРОЙКА MEMCACHED                  -----'
echo '------------------------------------------------------------------'
echo ''
AGAIN=yes
MEMCACHED_PORT=51211
while [ "${AGAIN}" = "yes" ]
do
    MEMCACHED_PORT_TEST=`netstat -tunlp | grep ${MEMCACHED_PORT}`
    if [ "${MEMCACHED_PORT_TEST}" = "" ]
    then
        AGAIN=no
    else
        MEMCACHED_PORT=$((MEMCACHED_PORT+1))
    fi
done
if [ "${VER}" = "jessie" ]
then
    cp /lib/systemd/system/memcached.service /lib/systemd/system/memcached_${DOMAIN}.service
    sed -i "s/memcached\.conf/memcached_${DOMAIN}.conf/g" /lib/systemd/system/memcached_${DOMAIN}.service
    systemctl enable memcached_${DOMAIN}.service
    systemctl start memcached_${DOMAIN}.service
    systemctl stop memcached.service
    systemctl disable memcached.service
fi
rm -rf /etc/memcached_${DOMAIN}.conf
cp /etc/memcached.conf /etc/memcached_${DOMAIN}.conf
rm -rf /etc/memcached.conf
sed -i "s/-p 11211/-p ${MEMCACHED_PORT}/g" /etc/memcached_${DOMAIN}.conf
sed -i "s/-M/# -M/g" /etc/memcached_${DOMAIN}.conf
echo "\n-I 3m" >> /etc/memcached_${DOMAIN}.conf
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                  НАСТРОЙКА CINEMAPRESS                 -----'
echo '------------------------------------------------------------------'
echo ''
if [ "${THEME}" != "skeleton" ]
then
    git clone https://github.com/CinemaPress/Theme-${THEME}.git /home/${DOMAIN}/themes/${THEME}
    chown -R ${DOMAIN}:www-data /home/${DOMAIN}/themes
    sed -i "s/\"theme\":\s*\".*\"/\"theme\":\"${THEME}\"/" /home/${DOMAIN}/config/config.js
fi
CRONTAB=`grep ${DOMAIN} /etc/crontab`
if [ "${CRONTAB}" = "" ]
then
    echo "\n" >> /etc/crontab
    echo "# -----" >> /etc/crontab
    echo "# ----- ${DOMAIN} --------------------------------------------" >> /etc/crontab
    echo "# -----" >> /etc/crontab
    echo "@hourly root node /home/${DOMAIN}/modules/publish.js >> /home/${DOMAIN}/config/autostart.log 2>&1" >> /etc/crontab
    echo "# ----- ${DOMAIN} --------------------------------------------" >> /etc/crontab
fi
sed -i "s/example\.com/${DOMAIN}/g" /home/${DOMAIN}/config/config.js
sed -i "s/:11211/:${MEMCACHED_PORT}/" /home/${DOMAIN}/config/config.js
sed -i "s/:9306/:${MYSQL_PORT}/" /home/${DOMAIN}/config/config.js
sed -i "s/:3000/:${NGINX_PORT}/" /home/${DOMAIN}/config/config.js
cp /home/${DOMAIN}/config/config.js /home/${DOMAIN}/config/config.old.js
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                    НАСТРОЙКА SYSCTL                    -----'
echo '------------------------------------------------------------------'
echo ''
mv /etc/sysctl.conf /etc/sysctl.old.conf
cp /home/${DOMAIN}/config/sysctl.conf /etc/sysctl.conf
sysctl -p
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                   НАСТРОЙКА FAIL2BAN                   -----'
echo '------------------------------------------------------------------'
echo ''
rm -rf /etc/fail2ban/jail.local
cp /home/${DOMAIN}/config/jail.conf /etc/fail2ban/jail.local
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                    НАСТРОЙКА IPTABLES                  -----'
echo '------------------------------------------------------------------'
echo ''
iptables -A INPUT -p tcp -s 127.0.0.1 --dport ${MEMCACHED_PORT} -j ACCEPT
iptables -A INPUT -p tcp --dport ${MEMCACHED_PORT} -j REJECT
iptables -A INPUT -p tcp -s 127.0.0.1 --dport ${MYSQL_PORT} -j ACCEPT
iptables -A INPUT -p tcp --dport ${MYSQL_PORT} -j REJECT
iptables -A INPUT -p tcp -s 127.0.0.1 --dport ${SPHINX_PORT} -j ACCEPT
iptables -A INPUT -p tcp --dport ${SPHINX_PORT} -j REJECT
iptables -A INPUT -p tcp -s 127.0.0.1 --dport ${NGINX_PORT} -j ACCEPT
iptables -A INPUT -p tcp --dport ${NGINX_PORT} -j REJECT
iptables-save >/etc/iptables/rules.v4
ip6tables-save >/etc/iptables/rules.v6
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                  УСТАНОВКА ЗАВИСИМОСТЕЙ                -----'
echo '------------------------------------------------------------------'
echo ''
cd /home/${DOMAIN}/
npm install --loglevel=silent --parseable
I=`npm list -g --depth=0 | grep "pm2"`
if ! [ -n "${I}" ]
then
    npm install --loglevel=silent --parseable pm2 -g
    sleep 2
    if [ "${VER}" = "jessie" ]
    then
        pm2 startup systemd
    else
        pm2 startup ubuntu
    fi
fi
pm2 start app.js --watch --ignore-watch "node_modules .* *.sh *.log *.conf *.xml *.txt *.jpg *.png *.gif *.css config/config.old.js config/config.new.js" --name="${DOMAIN}" --no-vizion
pm2 save
indexer --all --config "/home/${DOMAIN}/config/sphinx.conf" || indexer --all --rotate --config "/home/${DOMAIN}/config/sphinx.conf"
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '   _______ _                         ______                       '
echo '  (_______|_)                       (_____ \                      '
echo '   _       _ ____  _____ ____  _____ _____) )___ _____  ___  ___  '
echo '  | |     | |  _ \| ___ |    \(____ |  ____/ ___) ___ |/___)/___) '
echo '  | |_____| | | | | ____| | | / ___ | |   | |   | ____|___ |___ | '
echo '   \______)_|_| |_|_____)_|_|_\_____|_|   |_|   |_____|___/(___/  '
echo '                                                                  '
echo '------------------------------------------------------------------'
echo '-----                                                        -----'
echo '-----          УРА! CinemaPress CMS готова к работе!         -----'
echo '-----      Чтобы все заработало, требуется перезагрузка.     -----'
echo '-----        Сервер будет перезагружен через 10 сек ...      -----'
echo '-----                                                        -----'
echo '------------------------------------------------------------------'
echo '!!!!!      Нажмите CTRL+C ^C чтобы отменить перезагрузку     !!!!!'
echo ''
sleep 10
reboot