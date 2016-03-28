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
    if [ "${THEME}" = "ted" ] || [ "${THEME}" = "barney" ] || [ "${THEME}" = "lily" ] || [ "${THEME}" = "marshall" ]
    then
        AGAIN=no
    else
        echo 'WARNING: Нет такой темы.'
    fi
done
echo '------------------------------------------------------------------'
echo ''

if ! [ -d /home/${DOMAIN}/themes/${THEME} ]
then
    git clone https://github.com/CinemaPress/Theme-${THEME}.git /home/${DOMAIN}/themes/${THEME}
else
    echo ''
    echo '------------------------------------------------------------------'
    echo '!!!!!           Ваши изменения в теме будут удалены          !!!!!'
    echo '------------------------------------------------------------------'
    echo ''
    read -p 'Тема уже установлена, хотите обновить её? [ДА/нет] : ' YES

    if [ "${YES}" = "ДА" ] || [ "${YES}" = "Да" ] || [ "${YES}" = "да" ] || [ "${YES}" = "YES" ] || [ "${YES}" = "Yes" ] || [ "${YES}" = "yes" ] || [ "${YES}" = "Y" ] || [ "${YES}" = "y" ] || [ "${YES}" = "" ]
    then
        rm -rf /home/${DOMAIN}/themes/${THEME}
        git clone https://github.com/CinemaPress/Theme-${THEME}.git /home/${DOMAIN}/themes/${THEME}
    else
        exit 0
    fi
fi

SITE=`basename \`pwd\``

chown -R ${SITE}:www-data /home/${DOMAIN}/themes

echo ''
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
echo '---------                                                ---------'
echo '---------           Тема успешно импортирована!          ---------'
echo '---------      Измените название темы в админ-панели     ---------'
echo "                              ${THEME}                            "
echo '---------                                                ---------'
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
echo ''
