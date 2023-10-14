# Репозитории:
ab-haproxy -> https://github.com/klimantovich/ab-haproxy  
ab-logstash ->  https://github.com/klimantovich/ab-logstash  
ab-webui ->  https://github.com/klimantovich/ab-webui

# Хосты
10.0.5.10 -  LOGSTASH (rsyslog-сервер, logstash и elasticsearch)  
10.0.5.12 -  HAPROXY (прокси/load balancer для kibana)  
10.0.5.13 -  WEBUI (UI для elasticsearch - kibana, nginx как реверс-прокси для kibana)

# ab-haproxy
[Ссылка на репозиторий](https://github.com/klimantovich/ab-haproxy)  
В плейбуке определено 3 роли (apt, ntp, haproxy).  
Прописываем ip кибаны (webui) в переменную kibana_node_ip: 10.0.5.13, которая будет использована при создании бэкенда в темплейте конфигурации.  
Итого конфигурация файла `/etc/haproxy/haproxy.conf` содержит 1 backend, который перенаправляет на хост с kibana:  
```
...
frontend hafrontend
    bind *:80
    mode http
    default_backend habackend

backend habackend
    mode http
    balance roundrobin
    option forwardfor
    server node1 10.0.5.13:80 check
```

# ab-logstash
[Ссылка на репозиторий](https://github.com/klimantovich/ab-logstash)  

В плейбуке используется 5 ролей (apt, ntp, rsyslog-сервер, logstash, elasticsearch).  

### Java  
устанавливаем с помощью роли geerlingguy.java, в плейбуке в переменную java_packages указываем нужную версию джавы.  


### Elasticsearch
устанавливаем с помощью одноименной роли, в таске "Configure Elasticsearch" копируем темплейт кофиг файла. Предварительно нужно  
переопределить если нужно переменные (defaults):  
`elasticsearch_network_host: 0.0.0.0` - для возможности подключения к кластеру извне (по умолчанию стоит только с localhost)  
`elasticsearch_discovery_type: single-node` - т.к. в задании используется кластер состоящий из 1-й ноды  
`elasticsearch_http_port: 9200` - elasticsearch будет работать на стандартном порту 9200  

Проверяем работоспособность elastiicsearch, зайдя на машину и попробовав подключиться по логину/паролю.  
Предварительно пароль можно сбросить и получить новый командой `bin/elasticsearch-reset-password -u elastic` 

<img width="450" alt="Снимок экрана 2023-10-14 в 21 46 33" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/741a44f2-c6e5-43b9-bc86-904a4b61e72a">


### rsyslog-сервер
роль используется для настройки сервера rsyslog, на который будут отправляться логи rsyslog-демоном с машины webui, 
а затем rsyslog будет отправлять логи уже в logstash. 
В темплейте конфига rsyslog.conf расскоментируются строки ниже, и по порту 514 будут ожидаться логи от remote rsyslog.
```
# provides UDP syslog reception
module(load="imudp")
input(type="imudp" port="514")

# provides TCP syslog reception
module(load="imtcp")
input(type="imtcp" port="514")
```
В директорию /etc/rsyslog.d/ роль добавляет конфиг-файлы `01-json-template.conf` для преобразования логов в json-формат, и файл `60-output.conf`, в котором
прописана пересылка логов в логстеш по порту 10514 (localhost).  


### logstash
С помощью переменной `logstash_monitor_local_syslog: false` отключаем сбор логов с локального syslog. Роль копирует фильтры (в директорию
/etc/logstash/conf.d/):  
01-beats-input.conf - настройки инпута, добавил input от rsyslog (по 10514 порту, который настроил в роли rsyslog-server)
30-elasticsearch-output.conf - настройки аутпута:
```
output {
  elasticsearch {
    hosts => {{ logstash_elasticsearch_hosts | to_json }}    # В нашем случае - локалхост
    index => "rsyslog-%{+YYYY.MM.dd}"                        # Логи будут попадать в индекс с таким названием
    user => "logstash"                                       # Тут использую пользователя/пароль, которого создал вручную (см. ab-webui)
    password => "nfdje44FuaneYF"
  }
}
```
Теперь логи с rsyslog должны попадать в logstash в json-формате, а затем попадать в эластик в индекс rsyslog-*

# ab-webui
[Ссылка на репозиторий](https://github.com/klimantovich/ab-webui)  

В плейбуке используется 5 ролей (apt, ntp, rsyslog-client, kibana, nginx).  

### Rsyslog-client  
Роль - копия роли rsyslog для ab-logstash, но в данном случае строки `provides TCP/UDP syslog reception` закомментированы, а в 50-default.conf
добавлена строка `*.*							@{{ rsyslog_server_ip }}:514` для пересылки всех логов на удаленный хост на 514 порт.  

### Kibana
Для того, чтоб файл из темплейта с конфигурацией kibana был создан с правильными настройками, задаем переменные  
`kibana_elasticsearch_url`: "http://10.0.5.10:9200" -> по умолчанию localhost  
`kibana_elasticsearch_username` и `kibana_elasticsearch_password` используем pre-defined пользователя kibana_system и задаем для него пароль
также, как до этого задавали пароль пользователю elastic.  

### Nginx
Настраиваем nginx как реверс-прокси для kibana, для этого с помощью переменной `nginx_kibana_address` задаем url кибаны и настраиваем на него proxy-pass.
Роль создает новый vhost со следующими настройками:  
```
server {
        listen 80 default_server;
        root /var/www/html;
        server_name _;
        location / {
                proxy_pass {{ nginx_kibana_address }};
        }
}
```

# Настройка и проверка ELK-стека

Предварительно через фаерволл закрыл на хосте webui на порты 5601 и 80 (разрешил только на 80 порт извне с ip haproxy), чтоб зайти на UI kibana можно 
было только по ip 10.0.5.12 (haproxy).  
### Веб-интерфейс:  
<img width="795" alt="Снимок экрана 2023-10-14 в 22 28 09" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/662a1791-3611-4805-88b0-f7f5e3cf7a59">  

### Создаем index-pattern (для отображения в discovery:  
<img width="1217" alt="Снимок экрана 2023-10-14 в 22 29 59" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/b0e14747-4996-4e64-a7e1-7df213b32081">  

### Проверка индекса:
<img width="1622" alt="Снимок экрана 2023-10-14 в 22 33 51" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/58bada44-6f3e-4b6c-a481-5a430d5d9c79">

### Проверка логов:
<img width="809" alt="Снимок экрана 2023-10-14 в 22 36 02" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/b09696a4-d21d-46ed-a7e2-a86e0138ba0a">  
Как видим, логи идут с хоста webui, как и требовалось, и type: rsyslog.

### Общая конфигурация
В итоге конфигурация elk-стека выглядит следующим образом:  
HAPROXY перенаправляет на свой backend (nginx), который в свою очередь перенаправляет на ui кибана. Напрямую nginx & kibana закрыты фаерволом, и зайти на них
кроме как через haproxy нельзя.



