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
apt-get -y install nginx proftpd-basic nodejs openssl libltdl7 libodbc1 libpq5 fail2ban
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
rm -rf /home/${DOMAIN}/
rm -rf /home/${DOMAIN}/.??*
git clone https://github.com/CinemaPress/CinemaPress-CMS.git /home/${DOMAIN}
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
APP_PORT=33333
while [ "${AGAIN}" = "yes" ]
do
    APP_PORT_TEST=`netstat -tunlp | grep ${APP_PORT}`
    if [ "${APP_PORT_TEST}" = "" ]
    then
        AGAIN=no
    else
        APP_PORT=$((APP_PORT+1))
    fi
done
rm -rf /etc/nginx/conf.d/rewrite.conf
mv /home/${DOMAIN}/config/rewrite.conf /etc/nginx/conf.d/rewrite.conf
rm -rf /etc/nginx/conf.d/${DOMAIN}.conf
ln -s /home/${DOMAIN}/config/nginx.conf /etc/nginx/conf.d/${DOMAIN}.conf
sed -i "s/:52034/:${APP_PORT}/g" /home/${DOMAIN}/config/nginx.conf
sed -i "s/52034/${APP_PORT}/g" /home/${DOMAIN}/app.js
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
echo '-----                  НАСТРОЙКА CINEMAPRESS                 -----'
echo '------------------------------------------------------------------'
echo ''
if [ "${THEME}" != "skeleton" ]
then
    git clone https://github.com/CinemaPress/Theme-${THEME}.git /home/${DOMAIN}/themes/${THEME}
    chown -R ${DOMAIN}:www-data /home/${DOMAIN}/themes
    sed -i "s/\"theme\":\s*\".*\"/\"theme\":\"${THEME}\"/" /home/${DOMAIN}/config/config.js
fi
sed -i "s/example\.com/${DOMAIN}/g" /home/${DOMAIN}/config/config.js
cp /home/${DOMAIN}/config/config.js /home/${DOMAIN}/config/config.old.js
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
echo '-----                  УСТАНОВКА ЗАВИСИМОСТЕЙ                -----'
echo '------------------------------------------------------------------'
echo ''
cd /home/${DOMAIN}/
npm install --loglevel=silent --parseable
npm install --loglevel=silent --parseable pm2 -g
sleep 2
if [ "${VER}" = "jessie" ]
then
    pm2 startup systemd
else
    pm2 startup ubuntu
fi;
pm2 start app.js --watch --name="${DOMAIN}"
pm2 save
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