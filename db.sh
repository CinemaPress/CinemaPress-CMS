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
cp /dev/null /home/${DOMAIN}/config/movies.xml
service sphinxsearch start
echo "flush_all" | nc -q 2 localhost 11211
echo '------------------------------------------------------------------'
echo "Зайдите на сайт ${DOMAIN} для проверки, что все изменения"
echo "которые были внесены, удачно были приняты сервером."
echo "Если Вы ответите 'Нет', тогда сайт вернётся к предыдущему рабочему состочнию!"
echo "Всё работает? (ДА/нет)"
read WORK
WORK=${WORK:='ДА'}
if [ ${WORK} = "yes" ] || [ ${WORK} = "y" ] || [ ${WORK} = "Y" ] || [ ${WORK} = "да" ] || [ ${WORK} = "Да" ] || [ ${WORK} = "ДА" ]
then
AGAIN=no
echo '------------------------------------------------------------------'
echo 'База данных установлена, кэш очищен,'
echo "настройки для сайта ${DOMAIN} прописаны!"
echo 'ВАЖНО: Нельзя делать переиндексацию БД indexer --rotate,'
echo 'так как это удалит все данные!'
echo ''
echo 'Если что-то не работает, свяжитесь с Нами:'
echo 'email: support@cinemapress.org'
echo 'skype: cinemapress'
echo '------------------------------------------------------------------'
else
service sphinxsearch stop
rm -rf /var/lib/sphinxsearch/data/*
cp -R /var/lib/sphinxsearch/old/* /var/lib/sphinxsearch/data/
service sphinxsearch start
echo "flush_all" | nc -q 2 localhost 11211
echo '------------------------------------------------------------------'
echo "Сайт ${DOMAIN} вернулся к предыдущему рабочему состоянию!"
echo ''
echo 'Свяжитесь с Нами и Мы постараемся разабраться в этой проблеме:'
echo "email: support@cinemapress.org"
echo "skype: cinemapress"
echo '------------------------------------------------------------------'
fi