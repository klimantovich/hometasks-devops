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

