# Выбор приложения
Решено сделать docker-compose для найденного на гитхабе приложения  
[https://github.com/mmumshad/simple-webapp](https://github.com/mmumshad/simple-webapp)  
которое представляет собой простое веб-приложение на flask, в котором используется подключение к бд MySQL и
чтение данных из нее.

# Настройка образа веб-приложения
Создал Dockerfile для flask-приложения:
```
FROM python:3
WORKDIR /app
COPY . /app
ENV FLASK_APP=app.py
RUN pip install -r requirements.txt
CMD ["flask", "run", "--host=0.0.0.0"]
```
Докер берет базовый образ python:3, копирует приложение в директорию /app, устанавливает зависимости из файла requirements.txt и запускает тестовый сервер  

# Настройка docker-compose
Создал docker-compose.yml файл состоящий из двух контейнеров (база данных и приложение).
Контейнер с базой сделал на основе образа mysql:8.0.34, в него передал (в соотв. с документацией образа на dockerhub)
переменные окружения с логином/названием БД и тд (такие как прописаны в файле app.py для подключения к БД)
```
version: '3.3'
services:
  db:
    image: mysql:8.0.34
    restart: always
    environment:
      MYSQL_DATABASE: 'employee_db'
      MYSQL_USER: 'user'
      MYSQL_PASSWORD: 'password'
      MYSQL_ROOT_PASSWORD: 'root123'
    ports:
      - '3306:3306'
    expose:
      - '3306'
    volumes:
      - "./scripts/init.sql:/docker-entrypoint-initdb.d/init.sql"
  web:
    build: .
    restart: always
    environment:
      MYSQL_DATABASE_HOST: db
    depends_on:
      - db
    ports:
      - '5000:5000'
    expose:
      - '5000'
```
Чтоб автоматизировать создание таблицы и ее заполнение использовал функционал (из доки обораза на dockerhub) с 
директорией `/docker-entrypoint-initdb.d` -> при запуске контейнера запустится скрипт `init.sql` из папки scripts и
создаст таблицу и заполнит ее.
у контейнера web указал переменную окружения `MYSQL_DATABASE_HOST: db`, для подключения в удаленной базе (по умолчанию
используется localhost, см. код app.py):
```
mysql_database_host = 'MYSQL_DATABASE_HOST' in os.environ and os.environ['MYSQL_DATABASE_HOST'] or  'localhost'
app.config['MYSQL_DATABASE_HOST'] = mysql_database_host
```
пробросил порты (3306 для mysql и 5000 для flask app) наружу, установил depends_on: db для web контейнера (чтоб он ожидал
запуска mysql)  
Контейнер web будет собирать образ из Dockerfile.

# Проверка и запуск приложения
Запуск docker-compose
`docker-compose up -d`  
Проверка что контейнеры запустились:
```
vagrant@ubuntu-focal:~$ docker ps -a
CONTAINER ID   IMAGE          COMMAND                  CREATED              STATUS              PORTS                                                  NAMES
fb4027c95955   vagrant_web    "flask run --host=0.…"   About a minute ago   Up 54 seconds       0.0.0.0:5000->5000/tcp, :::5000->5000/tcp              vagrant_web_1
2e3b9dc7d6b0   mysql:8.0.34   "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   vagrant_db_1
```
Проверка что приложение работает:  
<img width="363" alt="Снимок экрана 2023-10-06 в 16 26 40" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/6719838b-4d2d-44b1-a1c2-1782b1bc8244">  
И проверка что соединение с БД есть и данные успешно читаются (для этого надо судя по описанию приложения в репозитории
перейти по url http://<IP>:5000/read%20from%20database):  
<img width="545" alt="Снимок экрана 2023-10-06 в 16 31 07" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/52e262fd-e01b-457f-b3d8-c73494dede13">  

# Трудности



