#!/bin/bash

echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
echo '-----                                                        -----'
echo '!!!!!                         ВАЖНО!                         !!!!!'
echo '!!!!!                                                        !!!!!'
echo '!!!!!       Один ключ предназначен для одного домена         !!!!!'
echo '!!!!!       и может быть использован только один раз!        !!!!!'
echo '!!!!!        Ключ обновления БД работает только для          !!!!!'
echo '!!!!!         доменов, для которых уже приобретена           !!!!!'
echo '!!!!!          база по тарифам Start или Expanded            !!!!!'
echo '-----                                                        -----'
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
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

searchd --stop --config "/home/${DOMAIN}/config/sphinx.conf"

NOW=$(date +%Y-%m-%d)

wget -O database.tar.gz --no-check-certificate http://database.cinemapress.org/${KEY}/${DOMAIN}

INDEX_DOMAIN=`echo ${DOMAIN} | sed -r "s/[^A-Za-z0-9]/_/g"`

mkdir -p /var/lib/sphinxsearch/data
mkdir -p /var/lib/sphinxsearch/old

rm -rf /var/lib/sphinxsearch/old/movies_${INDEX_DOMAIN}.*
rm -rf /var/lib/sphinxsearch/old/bests_${INDEX_DOMAIN}.*

cp -R /var/lib/sphinxsearch/data/movies_${INDEX_DOMAIN}.* /var/lib/sphinxsearch/old/
cp -R /var/lib/sphinxsearch/data/bests_${INDEX_DOMAIN}.* /var/lib/sphinxsearch/old/

rm -rf /var/lib/sphinxsearch/data/movies_${INDEX_DOMAIN}.*
rm -rf /var/lib/sphinxsearch/data/bests_${INDEX_DOMAIN}.*

tar -xzf database.tar.gz -C /var/lib/sphinxsearch/data

if [ -f "/var/lib/sphinxsearch/data/movies.spa" ]
then
    for file in `find /var/lib/sphinxsearch/data/movies.* -type f`
    do
        NEW_NAME=`echo ${file} | sed -r "s/movies/movies_${INDEX_DOMAIN}/g"`
        mv ${file} ${NEW_NAME}
    done
fi

if [ -f "/var/lib/sphinxsearch/data/bests.spa" ]
then
    for file in `find /var/lib/sphinxsearch/data/bests.* -type f`
    do
        NEW_NAME=`echo ${file} | sed -r "s/bests/bests_${INDEX_DOMAIN}/g"`
        mv ${file} ${NEW_NAME}
    done
fi

touch /var/lib/sphinxsearch/data/${NOW}.txt
searchd --config "/home/${DOMAIN}/config/sphinx.conf"

echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
echo '-----                                                        -----'
echo '-----         Зайдие в админ-панель и очистите кэш,          -----'
echo '-----          затем перейдите на сайт и убедитесь           -----'
echo '-----          что всё работает и БД была успешно            -----'
echo '-----                  принята сервером.                     -----'
echo '-----                                                        -----'
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'

echo 'Всё работает? (ДА/нет)'

read WORK

if [ "${WORK}" = "" ]
then
    WORK=yes
fi

if [ ${WORK} = "yes" ] || [ ${WORK} = "y" ] || [ ${WORK} = "Y" ] || [ ${WORK} = "да" ] || [ ${WORK} = "Да" ] || [ ${WORK} = "ДА" ]
then

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

    searchd --stop --config "/home/${DOMAIN}/config/sphinx.conf"

    sleep 5

    rm -rf /var/lib/sphinxsearch/data/movies_${INDEX_DOMAIN}.*
    rm -rf /var/lib/sphinxsearch/data/bests_${INDEX_DOMAIN}.*

    cp -R /var/lib/sphinxsearch/old/movies_${INDEX_DOMAIN}.* /var/lib/sphinxsearch/data/
    cp -R /var/lib/sphinxsearch/old/bests_${INDEX_DOMAIN}.* /var/lib/sphinxsearch/data/

    sleep 5

    searchd --config "/home/${DOMAIN}/config/sphinx.conf"

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