### Создание нескольких виртуальных машин
    Vagrant.configure("2") do |config|
      config.vm.define "vm1" do |vm1|
        // First VM config
      end
      config.vm.define "vm2" do |vm2|
        // Second VM config
      end
    end
### Конфигурация сети
    Cоздаем сетевые интерфейсы на обеих ВМ:
    vm1.vm.network "private_network", ip: "10.0.5.10"
    vm2.vm.network "private_network", ip: "10.0.5.11"
### Скрипты установки
    Был использован вариант inline скрипта, т.к. он короткий и нет необходимости выносить его в другой файл. 
    На первую вм для примера был установлен apache, на вторую - nginx.
    config.vm.provision "shell", inline: <<-SHELL
        apt update
        apt install apache2
    SHELL
### Запуск, взаимодействие и тестирование
    vagrant up - обе вм запустились и у каждой был запущен provision
    vagrant status
<img width="510" alt="Снимок экрана 2023-10-04 в 18 43 01" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/4f064b12-9d6b-4fb7-b2d7-5b9a37f9bd2e">  

    vagrant ssh vm1
    Провека установлены ли пакеты, указанные в скрипте, и проверка настроены ли сетевые интерфейсы
<img width="637" alt="Снимок экрана 2023-10-04 в 18 47 57" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/96e50ba2-a244-4ce1-b221-87b814c5665f">
<img width="723" alt="Снимок экрана 2023-10-05 в 12 14 18" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/64e34a46-f25c-4aea-aca1-93947a29e1f1">

    Проверяем что машины видят друг друга и могу взаимодействовать:
    ping -c 4 10.0.5.11 - пинг
    curl 10.0.5.11:80 - проверка что веб-сервера установлены и работают
    

