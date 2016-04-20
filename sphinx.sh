#!/bin/bash

echo ''
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
echo '---------------------------- IP ДОМЕНА ---------------------------'
AGAIN=yes
while [ "${AGAIN}" = "yes" ]
do
    if [ $2 ]; then
        IP=${2}
        echo ": ${IP}"
    else
        read -p ': ' IP
    fi
    if [ "${IP}" != "" ]
    then
        AGAIN=no
    else
        echo 'WARNING: IP на котором будет использоваться Sphinx не может быть пустым.'
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
echo "deb http://httpredir.debian.org/debian ${VER} main contrib non-free \n deb-src http://httpredir.debian.org/debian ${VER} main contrib non-free \n deb http://httpredir.debian.org/debian ${VER}-updates main contrib non-free \n deb-src http://httpredir.debian.org/debian ${VER}-updates main contrib non-free \n deb http://security.debian.org/ ${VER}/updates main contrib non-free \n deb-src http://security.debian.org/ ${VER}/updates main contrib non-free \n deb http://mirror.de.leaseweb.net/dotdeb/ ${VER} all \n deb-src http://mirror.de.leaseweb.net/dotdeb/ ${VER} all" > /etc/apt/sources.list
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                     ИМПОРТ КЛЮЧЕЙ                      -----'
echo '------------------------------------------------------------------'
echo ''
wget --no-check-certificate http://www.dotdeb.org/dotdeb.gpg; apt-key add dotdeb.gpg
rm -rf dotdeb.gpg
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                        УЛУЧШЕНИЕ                       -----'
echo '------------------------------------------------------------------'
echo ''
apt-get -y -qq update && apt-get -y -qq upgrade && apt-get -y -qq install mysql-client libltdl7 libodbc1 libpq5 fail2ban iptables-persistent
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                    НАСТРОЙКА SPHINX                    -----'
echo '------------------------------------------------------------------'
echo ''
mkdir -p /home/${DOMAIN}/config/
wget --no-check-certificate https://raw.githubusercontent.com/CinemaPress/CinemaPress-CMS/master/config/default/sphinx.conf -qO /home/${DOMAIN}/config/sphinx.conf
wget --no-check-certificate https://raw.githubusercontent.com/CinemaPress/CinemaPress-CMS/master/config/default/movies.xml -qO /home/${DOMAIN}/config/movies.xml
I=`dpkg -s sphinxsearch | grep "Status"`
if ! [ -n "${I}" ]
then
    wget --no-check-certificate http://sphinxsearch.com/files/sphinxsearch_2.2.10-release-1~${VER}_amd64.deb -qO s.deb && dpkg -i s.deb && rm -rf s.deb
    rm -rf /etc/sphinxsearch/sphinx.conf
    wget --no-check-certificate https://raw.githubusercontent.com/CinemaPress/CinemaPress-CMS/master/config/default/dummy.conf -qO /etc/sphinxsearch/sphinx.conf
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
sed -i "s/127\.0\.0\.1:9306/0\.0\.0\.0:${MYSQL_PORT}/g" /home/${DOMAIN}/config/sphinx.conf
sed -i "s/:9312/:${SPHINX_PORT}/g" /home/${DOMAIN}/config/sphinx.conf
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                    НАСТРОЙКА IPTABLES                  -----'
echo '------------------------------------------------------------------'
echo ''
iptables -A INPUT -p tcp -s ${IP} --dport ${MYSQL_PORT} -j ACCEPT
iptables -A INPUT -p tcp --dport ${MYSQL_PORT} -j REJECT
iptables -A INPUT -p tcp -s 127.0.0.1 --dport ${SPHINX_PORT} -j ACCEPT
iptables -A INPUT -p tcp --dport ${SPHINX_PORT} -j REJECT
iptables-save >/etc/iptables/rules.v4
ip6tables-save >/etc/iptables/rules.v6
MYSQL_IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                  НАСТРОЙКА АВТОЗАПУСКА                 -----'
echo '------------------------------------------------------------------'
echo ''
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
echo '-----                       ИНДЕКСИРУЕМ                      -----'
echo '------------------------------------------------------------------'
echo ''
indexer --all --config "/home/${DOMAIN}/config/sphinx.conf" || indexer --all --rotate --config "/home/${DOMAIN}/config/sphinx.conf"
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
echo '-----                                                        -----'
echo '-----            УРА! Sphinx сервер готов к работе!          -----'
echo '-----      Установите параметры Sphinx в CinemaPress CMS:    -----'
echo "                      ${MYSQL_IP}:${MYSQL_PORT}                   "
echo '-----      Чтобы все заработало, требуется перезагрузка.     -----'
echo '-----        Сервер будет перезагружен через 10 сек ...      -----'
echo '-----                                                        -----'
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
echo '-----                                                        -----'
echo '!!!!!      Нажмите CTRL+C ^C чтобы отменить перезагрузку     !!!!!'
echo '-----                                                        -----'
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
echo ''
sleep 10
reboot