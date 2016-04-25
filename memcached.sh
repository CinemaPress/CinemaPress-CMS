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
        echo 'WARNING: IP на котором будет использоваться кэширование не может быть пустым.'
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
apt-get -y -qq update && apt-get -y -qq upgrade && apt-get -y -qq install memcached fail2ban iptables-persistent
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
sed -i "s/-p 11211/-p ${MEMCACHED_PORT}/g" /etc/memcached_${DOMAIN}.conf
sed -i "s/-l 127\.0\.0\.1/-l 0\.0\.0\.0/g" /etc/memcached_${DOMAIN}.conf
sed -i "s/-m 64/-m 128/g" /etc/memcached_${DOMAIN}.conf
sed -i "s/-M/# -M/g" /etc/memcached_${DOMAIN}.conf
echo "\n-I 3m" >> /etc/memcached_${DOMAIN}.conf
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '-----                    НАСТРОЙКА IPTABLES                  -----'
echo '------------------------------------------------------------------'
echo ''
iptables -A INPUT -p tcp -s ${IP} --dport ${MEMCACHED_PORT} -j ACCEPT
iptables -A INPUT -p tcp --dport ${MEMCACHED_PORT} -j REJECT
iptables-save >/etc/iptables/rules.v4
ip6tables-save >/etc/iptables/rules.v6
MEMCACHED_IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo ''
echo '------------------------------------------------------------------'
echo '-----                           OK                           -----'
echo '------------------------------------------------------------------'
echo ''
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
echo '-----                                                        -----'
echo '-----          УРА! Memcached сервер готов к работе!         -----'
echo '-----       Установите параметры кэша в CinemaPress CMS:     -----'
echo "                      ${MEMCACHED_IP}:${MEMCACHED_PORT}           "
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