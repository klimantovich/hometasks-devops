### Настройка и запуск
    vagrant init
    ...
    Vagrant.configure("2") do |config|
      config.vm.box = "ubuntu/focal64"
      config.vm.network "forwarded_port", guest: 80, host: 8080
      config.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.cpus = 1
        vb.memory = "1024"
      end
    end
    ...
    vagrant up

### Настройка Ansible
    Установка последней версии (masOS) - с помощью Homebrew - brew install ansible
    ansible --version
<img width="975" alt="Снимок экрана 2023-10-05 в 13 05 53" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/bc902369-81e0-4aec-9ddf-26ca00834b5c">

    Сгенерировал глобальный конфиг файл ansible sudo ansible-config init --disabled > /etc/ansible/ansible.cfg
    Прописал путь до inventory файла: inventory=/etc/ansible/hosts
    в inventory файле создал одну группу [virtual_machines] с одним хостом vm1 (ip 10.0.5.10)
<img width="484" alt="Снимок экрана 2023-10-05 в 16 35 18" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/6911f498-1d10-487e-a247-9eb03f3c4ce4">

    Создал пользователя vklimantovich на ВМ, включил авторизацию по паролю (/etc/ssh/sshd_config -> PasswordAuthentication yes)
    Скопировал publickey на ВМ (ssh-copy-id vklimantovich@10.0.5.10), и обратно отключил PasswordAuthentication.
    Добавил vklimantovich в группу sudo и выключаем запрос пароля для sudo-команд (/etc/sudoers.d/vklimantovich).
    Проверяем работу запустив ad-hoc модуль ping:
<img width="520" alt="Снимок экрана 2023-10-05 в 16 37 43" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/e67c151a-79fc-46e0-a524-b54f389a3874">


### Настройка Ansible-плейбука

    Создал .yaml файл плейбука, содержащий необходимые таски. Для вывода даты в файл использовал 
    ansible fact ansible_date_time.iso8601, необходимые пакеты устанавливаю с помощью цикла with_items,
    cron настроил на срабатывание каждые 6 часов.
    Запуск плейбука -> ansible-playbook vmsetup.yaml
<img width="826" alt="Снимок экрана 2023-10-05 в 18 07 23" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/8062a3e5-8f8c-4eac-8756-6a18e8bd7e22">

    Заходим на ВМ и проверяем все ли корректно настроилось - vagrant ssh
    curl localhost:80 - проверяем установлена ли служба веб-сервера
    cat /home/vklimantovich/file.txt - проверяем создался ли файл с timestamp
    cat /etc/cron.d/ansible_clear-tmpdir - проверка создалась ли cronjob
<img width="432" alt="Снимок экрана 2023-10-05 в 18 14 06" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/af32245d-65da-44f2-87af-4b04bab79de8">

