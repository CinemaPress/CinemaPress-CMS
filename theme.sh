#!/bin/bash

echo ''
echo '---------------------- НАЗВАНИЕ ТЕМЫ -----------------------------'
if [ $1 ]
then
    THEME=${1}
    echo ${THEME}
else
    read THEME
    if [ "${THEME}" = "" ]
    then
        exit 0
    fi
fi
echo '------------------------------------------------------------------'
echo ''

if ! [ -d ./themes/${THEME} ]
then
    git clone https://github.com/CinemaPress/Theme-${THEME}.git ./themes/${THEME}
else
    echo 'Тема уже установлена, хотите обновить её (ДА/нет)?'
    echo '!!! ваши изменения в теме будут удалены !!!'
    read UPDATE
    if [ "${UPDATE}" = "" ]
    then
        UPDATE=yes
    fi

    if [ ${UPDATE} = "yes" ] || [ ${UPDATE} = "y" ] || [ ${UPDATE} = "Y" ] || [ ${UPDATE} = "да" ] || [ ${UPDATE} = "Да" ] || [ ${UPDATE} = "ДА" ]
    then
        rm -rf ./themes/${THEME}
        git clone https://github.com/CinemaPress/Theme-${THEME}.git ./themes/${THEME}
    else
        exit 0
    fi
fi

SITE=`basename \`pwd\``

chown -R ${SITE}:www-data ./config/config.js
chown -R ${SITE}:www-data ./themes

echo '---------------------------------------------------------'
echo '---------------------------------------------------------'
echo '-----                                               -----'
echo '-----          Тема успешно импортирована!          -----'
echo '-----     Измените название темы в админ-панели     -----'
echo "-----                    ${THEME}                   -----"
echo '-----                                               -----'
echo '---------------------------------------------------------'
echo '---------------------------------------------------------'