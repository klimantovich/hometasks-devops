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

