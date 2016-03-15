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

if ! [ -d ./themes/${THEME} ]; then
git clone https://github.com/CinemaPress/Theme-${THEME}.git ./themes/${THEME}
fi

chown -R :www-data ./config/config.js
chown -R :www-data ./themes

sed -i "s/\"theme\":\s*\".*\"/\"theme\":\"${THEME}\"/" ./config/config.js