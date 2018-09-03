FROM selenoid/vnc:chrome_68.0
USER root

ARG HDIMAGE_STORE_NAME=myStoreName
ARG HDIMAGE_STORE_PASSWORD=myStorePassword
ARG CERT_FILE_NAME=mayCertName.cer
#ARG CSP_LICENSE_KEY=
ARG USER_NAME=selenium

ADD dist/ /tmp/dist/
ADD cert/ /tmp/cert/

RUN tar -zxf /tmp/dist/linux-amd64_deb.tgz -C /tmp/dist/
RUN tar -xzf /tmp/dist/cades_linux_amd64.tar.gz -C /tmp/dist/

# Установка КриптоПро CSP 4.0
RUN /tmp/dist/linux-amd64_deb/install.sh


# Номер лицензии (Если у вас есть лицензионный ключ, необходимо раскоментировать следующую строку и
# подставить свой серийный ключ вместо $CSP_LICENSE_KEY и раскоментировать его !!!)
#RUN /opt/cprocsp/sbin/amd64/cpconfig -license -set $CSP_LICENSE_KEY

# Проверка лицензии
RUN /opt/cprocsp/sbin/amd64/cpconfig -license -view


# Перенос закрытого ключа в HDIMAGE
RUN mkdir -p /var/opt/cprocsp/keys/$USER_NAME/$HDIMAGE_STORE_NAME.000 && mv /tmp/cert/$HDIMAGE_STORE_NAME.000/ /var/opt/cprocsp/keys/$USER_NAME/
# даем права на чтение закрытого ключа пользователю $USER_NAME
RUN chown $USER_NAME /var/opt/cprocsp/keys/$USER_NAME/ -R

USER $USER_NAME
# Добавляем сертификат в хранилище (от пользователя которым производим подпись)
RUN /opt/cprocsp/bin/amd64/certmgr -inst -file /tmp/cert/$CERT_FILE_NAME -cont "\\\\.\\HDIMAGE\\$HDIMAGE_STORE_NAME"
# Убираем пароль, чтобы он не кидал alert (Если хранилище уже не запаролено, то закоментить следующую строку)
RUN /opt/cprocsp/bin/amd64/csptest -passwd -change '' -cont "\\\\.\\HDIMAGE\\$HDIMAGE_STORE_NAME" -passwd $HDIMAGE_STORE_PASSWORD

USER root
# Устанавливаем alien для rpm пакетов
RUN apt update && apt-get install alien -y
# Устанвока КриптоПро ЭЦП Browser plug-in содержит необходимые библиотеки для компиляции и исходники расширений
RUN alien -kci /tmp/dist/cprocsp-pki-2.0.0-amd64-cades.rpm
RUN alien -kci /tmp/dist/cprocsp-pki-2.0.0-amd64-plugin.rpm
# убираем alert "переход на новый алгоритм в 2019 году
# см. https://support.cryptopro.ru/index.php?/Knowledgebase/Article/View/226/0/otkljuchenie-preduprezhdjushhikh-okon-o-neobkhodimosti-skorogo-perekhod-n-gost-r-3410-2012
RUN sed -i 's/\[Parameters\]/[Parameters]\nwarning_time_gen_2001=ll:131907744000000000\nwarning_time_sign_2001=ll:131907744000000000/g' /etc/opt/cprocsp/config64.ini

ADD mount/resources/ /home/$USER_NAME/resources/
USER $USER_NAME