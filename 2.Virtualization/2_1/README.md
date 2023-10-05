## Инициализация проекта:
Инициализация: `vagrant init`  
   <img width="505" alt="Снимок экрана 2023-10-04 в 17 43 44" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/07ad5233-0163-4f13-ad34-ee787a2e0d8e">

## Настройка Vagrantfile
  На vagrant cloud найден образ `https://app.vagrantup.com/ubuntu/boxes/focal64` с ubuntu20.04  
  Создана vm с 1024 memory & 1 cpu, настроен port_forwarding с 8080 порта хост-машины на 80 порт виртаульной машины (см. Vagrantfile)

## Запуск и подключение
```
vagrant up  
vagrant ssh   
```
  <img width="444" alt="Снимок экрана 2023-10-04 в 18 03 43" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/3a83fad4-4d4d-44ed-94e5-b67c06daf4d1">

## Выключение и уничтожение
Логаут с ВМ - exit
```    
vagrant halt  
vagrant destroy
```
  <img width="523" alt="Снимок экрана 2023-10-04 в 18 09 58" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/78d06d81-5142-4d29-915d-5b886b3a3224">
