# Selenoid контейнер с КриптоПро CSP 4.0 (Клиентская подпись для Selenium тестов)
aerokube/selenoid контейнер (https://github.com/aerokube/selenoid/) + HDIMAGE Store + CADES

### Сборка
Аргументы Dockerfile:
1. HDIMAGE_STORE_NAME - имя хранилища ключей на диске (пример: из **myStore.000** нужно взять только **myStore**). 
Должен лежать в папке _cert_
1. HDIMAGE_STORE_PASSWORD - пароль хранилища ключей на диске
1. CERT_FILE_NAME - Имя личного сертификат с расширением *.cer* (пример: private_certificate.cer). Должен лежать в папке _cert_
1. CSP_LICENSE_KEY - Ключ активации КриптоПро CSP 4.0 (Раскоментировать строки _ARG CSP_LICENSE_KEY=_ и _RUN /opt/cprocsp/sbin/amd64/cpconfig -license -set $CSP_LICENSE_KEY_)
1. USER_NAME=selenium - Имя пользователя от которого будет производиться запуск драйвера (Default: selenium)

Запуск контейнера:

        docker build /path/to/project/folder -t selenoid_cryptopro_csp

В составе Selenoid:
1. Добавить в /Users/ghostcky/.aerokube/selenoid/browsers.json новый контейнер для Chrome:

    ``` json
    "chrome": {
        "versions": {
            "selenoid_cryptopro_csp": {
                "image": "selenoid_cryptopro_csp:latest",
                "port": "4444",
                "path": "/",
                "tmpfs": {
                    "/tmp": "size=128m"
                }
            }
        }
    }
    ```
    
2. Перезапустить selenoid

Standalone:
   
1. docker run selenoid_cryptopro_csp

Документацию по развертыванию Selenoid см. на https://github.com/aerokube/selenoid/

### Поддержка браузеров
Контейнер протестирован на Google Chrome 68.0. 
Для создения контейнера на основе другого браузера необходимо изменить первую строку в Dockerfile **"FROM selenoid/vnc:chrome_68.0"** выбрав из
имеющихся в открытом доступе (https://github.com/aerokube/selenoid/blob/master/docs/browser-image-information.adoc)
