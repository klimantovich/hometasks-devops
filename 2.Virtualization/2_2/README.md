### Создание нескольких виртуальных машин
    Vagrant.configure("2") do |config|
      config.vm.define "vm1" do |vm1|
        // First VM config
      end
      config.vm.define "vm2" do |vm2|
        // Second VM config
      end
    end

