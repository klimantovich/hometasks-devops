# Установка Jenkins
Установку производил на ВМ с Ubuntu:20.04 (поднятую Vagrant-ом) согласно инструкции [https://www.jenkins.io/doc/book/installing/linux/](https://www.jenkins.io/doc/book/installing/linux/)
Т.к. было выбрано для задания приложение [https://github.com/wickett/word-cloud-generator](https://github.com/wickett/word-cloud-generator) на Golang
то отключил ненужные плагины (которые по умолчанию предлагает установить jenkins)
И сделал форк репозитория -> [https://github.com/klimantovich/word-cloud-generator](https://github.com/klimantovich/word-cloud-generator)
<img width="1325" alt="Снимок экрана 2023-10-06 в 17 57 52" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/b1e61fcc-f17f-483f-b05a-b3eb0109d402">
Установил доп.плагины:
- Docker Pipeline -> для использования docker-контейнеров из пайплайнов
- Pipeline -> для создания jenkins-пайплайнов
  
# Создание проекта по сборке приложения
Создал новый item c названием Staging с типом проекта Pipeline.  
Добавляем параметр $GIT_BRANCH для возможности выбора ветки
<img width="911" alt="Снимок экрана 2023-10-08 в 15 28 42" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/6eb54c5f-a0c4-4761-b2df-fb46f8010ab1">  

Выбрал "Pipeline script from SCM" для того чтоб Jenkinsfile брался из git-репозитория, ветку указал взять из параметра $GIT_BRANCH  
В поле "Script Path" указал пусть до Jenkinsfile (т.к. он находится в корне репозитория, оставил как есть).  
<img width="905" alt="Снимок экрана 2023-10-08 в 15 34 13" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/5ca7c612-a3db-4d41-9a7e-3d1ac1b927df">  

В git репозитории проекта создал ветку staging и в корне создал Jenkinsfile с двумя этапами:
```
pipeline {
    agent any    # стандартные этапы могут выполняться на любом агенте
    stages {
        stage('Clone project') {
            steps {
                git 'https://github.com/klimantovich/word-cloud-generator'    # делаем git clone проекта из репозитория (плагин Git)
            }
        }
        stage('Build project') {
            agent {
                docker { image 'golang:1.16' }    # Собирал проект в докер-контейнере на основе образа с Go version 1.16
            }
            steps {
                sh '''
                GOCACHE="$WORKSPACE/.gocache" GOOS=linux GOARCH=amd64 go build -o ./artifacts/word-cloud-generator-$BUILD_NUMBER  
                gzip artifacts/word-cloud-generator-$BUILD_NUMBER
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

# NEXT
