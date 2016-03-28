#!/bin/bash

echo ''
echo '--------------------------- URL ДОМЕНА ---------------------------'
AGAIN=yes
while [ "${AGAIN}" = "yes" ]
do
    if [ $1 ]; then
        DOMAIN=${1}
        echo ${DOMAIN}
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
echo '------------------------------------------------------------------'
echo ''

sleep 3

mkdir -p /home/${DOMAIN}/.newCP
mkdir -p /home/${DOMAIN}/.oldCP

rm -rf /home/${DOMAIN}/.newCP
rm -rf /home/${DOMAIN}/.oldCP

git clone https://github.com/CinemaPress/CinemaPress-CMS.git /home/${DOMAIN}/.newCP
cp -R /home/${DOMAIN}/* /home/${DOMAIN}/.oldCP

rm -rf /home/${DOMAIN}/package.json && cp -R /home/${DOMAIN}/.newCP/package.json /home/${DOMAIN}/package.json
rm -rf /home/${DOMAIN}/app.js && cp -R /home/${DOMAIN}/.newCP/app.js /home/${DOMAIN}/app.js
rm -rf /home/${DOMAIN}/modules/* && cp -R /home/${DOMAIN}/.newCP/modules/* /home/${DOMAIN}/modules/
rm -rf /home/${DOMAIN}/routes/* && cp -R /home/${DOMAIN}/.newCP/routes/* /home/${DOMAIN}/routes/
rm -rf /home/${DOMAIN}/themes/skeleton/* && cp -R /home/${DOMAIN}/.newCP/themes/skeleton/* /home/${DOMAIN}/themes/skeleton/

rm -rf /home/${DOMAIN}/db.sh && cp -R /home/${DOMAIN}/.newCP/db.sh /home/${DOMAIN}/db.sh
rm -rf /home/${DOMAIN}/theme.sh && cp -R /home/${DOMAIN}/.newCP/theme.sh /home/${DOMAIN}/theme.sh
rm -rf /home/${DOMAIN}/update.sh && cp -R /home/${DOMAIN}/.newCP/update.sh /home/${DOMAIN}/update.sh

sleep 3

echo ''
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
echo '-----                                                        -----'
echo '-----         Зайдие в админ-панель и очистите кэш,          -----'
echo '-----          затем перейдите на сайт и убедитесь           -----'
echo '-----       что всё работает и изменения были успешно        -----'
echo '-----                  приняты сервером.                     -----'
echo '-----                                                        -----'
echo '------------------------------------------------------------------'
echo '------------------------------------------------------------------'
echo ''
read -p 'Всё работает? [ДА/нет] : ' YES

if [ "${YES}" = "ДА" ] || [ ${YES} = "Да" ] || [ ${YES} = "да" ] || [ ${YES} = "YES" ] || [ ${YES} = "Yes" ] || [ ${YES} = "yes" ] || [ ${YES} = "Y" ] || [ ${YES} = "y" ] || [ ${YES} = "" ]
then

    echo ''
    echo '------------------------------------------------------------------'
    echo '------------------------------------------------------------------'
    echo '-----                                                        -----'
    echo '-----          CinemaPress CMS успешно обновлена!            -----'
    echo '-----                                                        -----'
    echo '-----       Если что-то не работает, свяжитесь с Нами.       -----'
    echo '-----             email: support@cinemapress.org             -----'
    echo '-----             skype: cinemapress                         -----'
    echo '-----                                                        -----'
    echo '------------------------------------------------------------------'
    echo '------------------------------------------------------------------'
    echo ''

else

    rm -rf /home/${DOMAIN}/package.json && cp -R /home/${DOMAIN}/.oldCP/package.json /home/${DOMAIN}/package.json
    rm -rf /home/${DOMAIN}/app.js && cp -R /home/${DOMAIN}/.oldCP/app.js /home/${DOMAIN}/app.js
    rm -rf /home/${DOMAIN}/modules/* && cp -R /home/${DOMAIN}/.oldCP/modules/* /home/${DOMAIN}/modules/
    rm -rf /home/${DOMAIN}/routes/* && cp -R /home/${DOMAIN}/.oldCP/routes/* /home/${DOMAIN}/routes/
    rm -rf /home/${DOMAIN}/themes/skeleton/* && cp -R /home/${DOMAIN}/.oldCP/themes/skeleton/* /home/${DOMAIN}/themes/skeleton/

    rm -rf /home/${DOMAIN}/db.sh && cp -R /home/${DOMAIN}/.oldCP/db.sh /home/${DOMAIN}/db.sh
    rm -rf /home/${DOMAIN}/theme.sh && cp -R /home/${DOMAIN}/.oldCP/theme.sh /home/${DOMAIN}/theme.sh
    rm -rf /home/${DOMAIN}/update.sh && cp -R /home/${DOMAIN}/.oldCP/update.sh /home/${DOMAIN}/update.sh

    sleep 3

    echo ''
    echo '------------------------------------------------------------------'
    echo '------------------------------------------------------------------'
    echo '-----                                                        -----'
    echo '-----        CinemaPress CMS вернулась к предыдущему         -----'
    echo '-----                  рабочему состоянию!                   -----'
    echo '-----       Свяжитесь с Нами, постараемся разобраться.       -----'
    echo '-----             email: support@cinemapress.org             -----'
    echo '-----             skype: cinemapress                         -----'
    echo '-----                                                        -----'
    echo '------------------------------------------------------------------'
    echo '------------------------------------------------------------------'
    echo ''

fi