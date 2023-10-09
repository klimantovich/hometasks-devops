# Установка Jenkins
Установку производил на ВМ с Ubuntu:20.04 (поднятую Vagrant-ом) согласно инструкции [https://www.jenkins.io/doc/book/installing/linux/](https://www.jenkins.io/doc/book/installing/linux/)
Т.к. было выбрано для задания приложение [https://github.com/wickett/word-cloud-generator](https://github.com/wickett/word-cloud-generator) на Golang
то отключил ненужные плагины (которые по умолчанию предлагает установить jenkins)
И сделал форк репозитория -> [https://github.com/klimantovich/word-cloud-generator](https://github.com/klimantovich/word-cloud-generator)
<img width="1325" alt="Снимок экрана 2023-10-06 в 17 57 52" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/b1e61fcc-f17f-483f-b05a-b3eb0109d402">
Установил доп.плагины:
- Docker Pipeline -> для использования docker-контейнеров из пайплайнов
- Pipeline -> для создания jenkins-пайплайнов
- SSH-agent -> для поключения к серверам по ssh
  
# Сборка приложения
Создал новый item c названием Staging с типом проекта Pipeline.  
Добавляем параметр $GIT_BRANCH для возможности выбора ветки и SERVER_IP для выбора хоста, на который будем деплоить.
<img width="911" alt="Снимок экрана 2023-10-08 в 15 28 42" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/6eb54c5f-a0c4-4761-b2df-fb46f8010ab1">  

Выбрал "Pipeline script from SCM" для того чтоб Jenkinsfile брался из git-репозитория, ветку указал взять из параметра $GIT_BRANCH  
В поле "Script Path" указал пусть до Jenkinsfile (т.к. он находится в корне репозитория, оставил как есть).  
<img width="905" alt="Снимок экрана 2023-10-08 в 15 34 13" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/5ca7c612-a3db-4d41-9a7e-3d1ac1b927df">  

В git репозитории проекта создал ветку staging и в корне создал Jenkinsfile с двумя этапами:

```
pipeline {
    agent {
        docker { image 'golang:1.16' }
    }
    stages {
        stage('Git clone') {
            steps {
                git branch: '$GIT_BRANCH', url: 'https://github.com/klimantovich/word-cloud-generator'
            }
        }
        stage('Go build') {
            steps {
                sh '''
                  GOCACHE="$WORKSPACE/.gocache" GOOS=linux GOARCH=amd64 go build -o ./artifacts/word-cloud-generator-$BUILD_NUMBER
                  gzip ./artifacts/word-cloud-generator-$BUILD_NUMBER
                '''
            }
        }
    }
}
```

На этапе сборки проекта было решено собрать его в контейнере на основе GO image; В контейнере запустил go build команду, которая  
собрала проект и поместила его в директорию ./artifacts в рабочей директории проекта, а затем сжало его утилитой gzip.  
к имени артифакта при сборке будет прибавляться предустановленная переменная $BUILD_NUMBER, чтобы отличать артифакты разных сборок.

Запустил пайплайн и проверил что всё завершилось без ошибок:
<img width="639" alt="Снимок экрана 2023-10-08 в 15 49 43" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/ae78e52d-08cf-4766-b702-d739a2360a08">

Зашел в сборку и в workspace. Проверил что появилась директория ./artifacts в которой находится артифакт сборки  
<img width="545" alt="Снимок экрана 2023-10-08 в 15 53 07" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/1a81eb2d-7f4d-466d-a737-bddb4814b298">

# Деплой и тестирование (Staging)
Решил деплоить локально на виртуальную машину, которую поднял вагрантом.
Предварительно создал на ней пользователя jenkins и создал credentials для доступа с дженкинса на хост (username + private key):  
<img width="1129" alt="Снимок экрана 2023-10-09 в 16 10 36" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/b17d6105-c5c7-4c9a-a75c-da028b4928e0">  
Также оздал заготовку systemd-юнита (т.к. решил деплоить приложение как сервис systemd)
```
[Unit]
Description=Word Cloud Generator

[Service]
WorkingDirectory=/home/jenkins
ExecStart=/home/jenkins/word-cloud-generator
Restart=always

[Install]
WantedBy=multi-user.target
```
Добавил stages для деплоя в JENKINSFILE (полная версия тут -> [Jenkinsfile](https://github.com/klimantovich/word-cloud-generator/blob/staging/Jenkinsfile)  
Т.к. артефакт собирался в докер-контейнере, то передал его с помощью stash в следующие стейджи.
Использовал плагин ssh-agent для подключения по ssh к серверу для бекапа приложения и деплоя.
```
sshagent(credentials : ['deploy_server_credentials']) {
    sh 'ssh jenkins@$SERVER_IP sudo systemctl stop wordcloud.service'
    sh 'scp ./artifacts/word-cloud-generator-$BUILD_NUMBER.gz jenkins@$SERVER_IP:/home/jenkins/word-cloud-generator.gz'
    sh 'ssh jenkins@$SERVER_IP gunzip -f -q /home/jenkins/word-cloud-generator.gz'
    sh 'ssh jenkins@$SERVER_IP sudo systemctl start wordcloud.service'
}
```
на шаге деплоя я:
- Использую предустановленные credentials (созданные мной ранее, username+private key)
- останавливаю юнит wordcloud.service
- копирую артефакт в директорию, из которой systemd-сервис запускает приложение
- разархивирую артефакт
- запускаю сервис

На этапе тестирования я пытаюсь подключиться к задеплоенному приложению (которое работает сейчас на порту :8888)  
Запуск:  
<img width="903" alt="Снимок экрана 2023-10-09 в 16 27 51" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/74101368-6ac8-4932-bac1-2c1755290c96">  
Проверка пайплайна:  
<img width="1357" alt="Снимок экрана 2023-10-09 в 16 26 59" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/389fb58d-937f-4115-8ea6-d0d39646b980">  
Подключаемся к staging хосту по ip 10.0.5.11:8888, сервис задеплоен!
<img width="769" alt="Снимок экрана 2023-10-09 в 16 29 16" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/1f622298-ac98-4f7c-a555-870d11da4e0f">  

Т.к сервис задеплоен локально (и создать webhook для github не получится), то решил настроить взаимодействие с гитхаб путем  
поллинга github-репозитория раз в 30 минут (и при наличии изменении - триггерить пайплайн).  
Для этого в настройках проекта в "Build Triggers" выбрал "Poll SCM" и в расписании задал "H/30 * * * *"  

# Сборка & Деплой (Production)
Для продакшена все шаги практически идентичны.
Поднял отдельную ВМ вагрантом с ip 10.0.5.12, создал в master ветке jenkinsfile с кодом пайплайна.
Так же настроил credentials для ssh.
Так же как и для staging, настроил поллинг раз в 30 минут и автоматический запуск при изменениях в репозитории
Запуск пайплайна:  
<img width="233" alt="Снимок экрана 2023-10-09 в 16 50 32" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/a08871a1-219b-4d62-9038-60fc71ddffde">  
<img width="998" alt="Снимок экрана 2023-10-09 в 16 51 32" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/02aa4dd7-ff83-4b42-9354-d26d2721b65d">  
Заходим на 10.0.5.12:8888  
<img width="357" alt="Снимок экрана 2023-10-09 в 16 52 21" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/117750e6-d2c1-409c-b6d7-69efe3e7d896">  
Всё работает.




