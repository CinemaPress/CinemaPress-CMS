#!/bin/bash

echo ''
echo '------------------------ THEME -----------------------------------'
if [ $1 ]; then
THEME=${1}
echo ${THEME}
else
read THEME
THEME=${THEME:='skeleton'}
fi
echo '------------------------------------------------------------------'
echo ''

if ! [ -d ./themes/${THEME} ]
then
git clone https://github.com/CinemaPress/Theme-${THEME}.git ./themes/${THEME}
fi

SITE=`basename \`pwd\``

chown -R ${SITE}:www-data ./config/config.js
chown -R ${SITE}:www-data ./themes

echo '---------------------------------------------------------'
echo '---------------------------------------------------------'
echo '-----                                               -----'
echo '-----          Тема успешно импортирована!          -----'
echo '-----     Измените название темы в админ панели     -----'
echo "-----                    ${THEME}                   -----"
echo '-----                                               -----'
echo '---------------------------------------------------------'
echo '---------------------------------------------------------'