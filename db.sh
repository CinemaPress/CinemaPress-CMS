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
echo '---------------------- КЛЮЧ ДОСТУПА ------------------------------'
AGAIN=yes
while [ "$AGAIN" = "yes" ]
do
if [ $2 ]; then
KEY=${2}
echo ${KEY}
else
read KEY
fi
if [ ${KEY} ]; then
AGAIN=no
else
echo 'WARNING: Ключ не может быть пустым.'
fi
done
echo '------------------------------------------------------------------'
echo ''

sleep 3

service sphinxsearch stop

NOW=$(date +%Y-%m-%d)

wget -O database.tar.gz --no-check-certificate http://cinemapress.org/download/${KEY}

mkdir -p /var/lib/sphinxsearch/data
mkdir -p /var/lib/sphinxsearch/old
rm -rf /var/lib/sphinxsearch/old/*
cp -R /var/lib/sphinxsearch/data/* /var/lib/sphinxsearch/old/
rm -rf /var/lib/sphinxsearch/data/*
tar -xzf database.tar.gz -C /var/lib/sphinxsearch/data
touch /var/lib/sphinxsearch/data/${NOW}.txt
rm -rf /var/lib/sphinxsearch/data/*.spl
rm -rf /var/lib/sphinxsearch/data/binlog.*
cp /dev/null /home/${DOMAIN}/config/movies.xml
service sphinxsearch start
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
echo '-----                                                        -----'
echo '-----         Зайдие в админ панель и очистите кэш,          -----'
echo '-----          затем перейдите на сайт и убедитесь           -----'
echo '-----          что всё работает и БД была успешно            -----'
echo '-----                  принята сервером.                     -----'
echo '-----                                                        -----'
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
echo 'Всё работает? (ДА/нет)'
read WORK
WORK=${WORK:='ДА'}
if [ ${WORK} = "yes" ] || [ ${WORK} = "y" ] || [ ${WORK} = "Y" ] || [ ${WORK} = "да" ] || [ ${WORK} = "Да" ] || [ ${WORK} = "ДА" ]
then
AGAIN=no
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
echo '-----                                                        -----'
echo '-----          БД CinemaPress успешно установлена!           -----'
echo '-----                                                        -----'
echo '-----       Если что-то не работает, свяжитесь с Нами:       -----'
echo '-----             email: support@cinemapress.org             -----'
echo '-----             skype: cinemapress                         -----'
echo '-----                                                        -----'
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
else
service sphinxsearch stop
rm -rf /var/lib/sphinxsearch/data/*
cp -R /var/lib/sphinxsearch/old/* /var/lib/sphinxsearch/data/
service sphinxsearch start
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
echo '-----                                                        -----'
echo '-----          База данных вернулась к предыдущему           -----'
echo '-----                  рабочему состоянию!                   -----'
echo '-----       Свяжитесь с Нами, постараемся разобраться:       -----'
echo '-----             email: support@cinemapress.org             -----'
echo '-----             skype: cinemapress                         -----'
echo '-----                                                        -----'
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
fi