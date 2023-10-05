# Установка и настройка docker
Использовал ВМ с ubuntu-20.04, docker устанавливал с помощью apt (`apt install docker.io`)
Добавил юзера vagrant в группу docker (`sudo usermod -aG docker vagrant`) чтоб была
возможность запускать docker команды без sudo
Проверка -> `docker run hello-world`

  <img width="563" alt="Снимок экрана 2023-10-05 в 18 41 41" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/00ee2a8a-3087-4ca8-bc63-4766bdab0e83">

# Создание веб-приложения
Используется flask приложение, выводящее на экран надпись "hello, Docker!"
```
vagrant@ubuntu-focal:~$ ls
Dockerfile  __pycache__  app.py  requirements.txt
```
В файле requirements.txt указываем необходимые зависимости

# Создание Dockerfile
Базовый образ - `python:latest`  
Копируем файлы приложения в директорию /app (и делаем ее рабочей директорией) `COPY . /app`  
Устанавливаем зависимости `pip install -r requirements.txt`  
Запускаем приложение `CMD ["flask", "run", "--host=0.0.0.0"]`  

Создание образа из Dockerfile -> `docker build -t myapp .`

<img width="606" alt="Снимок экрана 2023-10-05 в 20 10 39" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/d07497e8-d0f2-41d3-bd58-d19ec852782b">

Проверка создан ли образ
```
vagrant@ubuntu-focal:~$ docker images
REPOSITORY    TAG       IMAGE ID       CREATED              SIZE
myapp         latest    11c83274b134   About a minute ago   1.04GB
python        latest    e5f0ac29ea7f   2 days ago           1.02GB
hello-world   latest    9c7a54a9a43c   5 months ago         13.3kB
```
# Запуск контейнера
Запуск контейнера с образом myapp без привязки к терминалу и с настройкой, чтоб контейнер удалился
после остановки. Так же пробрасываем порт 5000 наружу контейнера
`docker run -d --rm -p 5000:5000 myapp`
Проверка запущен ли контейнер
```
vagrant@ubuntu-focal:~$ docker ps -a
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                                       NAMES
be1c927eda79   myapp     "flask run --host=0.…"   32 seconds ago   Up 31 seconds   0.0.0.0:5000->5000/tcp, :::5000->5000/tcp   great_johnson
```
Финальная проверка того, что приложение запущено и работает и к нему можно подключиться с хост-машины
<img width="426" alt="Снимок экрана 2023-10-05 в 20 19 20" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/7cf1b79b-2925-4108-9313-b963a49b6696">


