#!/bin/bash

echo ''
echo '------------------------- НАЗВАНИЕ ТЕМЫ --------------------------'
AGAIN=yes
while [ "$AGAIN" = "yes" ]
do
    if [ $2 ]
    then
        THEME=${2}
        echo ${THEME}
    else
        read -e -p ': ' THEME
        if [[ "${THEME}" = "ted" || "${THEME}" = "barney" || "${THEME}" = "lily" || "${THEME}" = "marshall" ]]
        then
            AGAIN=no
        else
            echo 'WARNING: Нет такой темы.'
        fi
    fi
done
echo '------------------------------------------------------------------'
echo ''

if ! [ -d ./themes/${THEME} ]
then
    git clone https://github.com/CinemaPress/Theme-${THEME}.git ./themes/${THEME}
else
    echo ''
    echo '------------------------------------------------------------------'
    echo '-----                                                        -----'
    echo '!!!!!           Ваши изменения в теме будут удалены          !!!!!'
    echo '-----                                                        -----'
    echo '------------------------------------------------------------------'
    echo ''
    read -e -p 'Тема уже установлена, хотите обновить её? [ДА/нет] : ' YES

    if [[ "${YES}" = "ДА" || ${YES} = "Да" || ${YES} = "да" || ${YES} = "YES" || ${YES} = "Yes" || ${YES} = "yes" || ${YES} = "Y" || ${YES} = "y" || ${YES} = "" ]]
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

echo ''
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
echo '---------                                                ---------'
echo '---------           Тема успешно импортирована!          ---------'
echo '---------      Измените название темы в админ-панели     ---------'
echo "---------                     ${THEME}                   ---------"
echo '---------                                                ---------'
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
echo ''
