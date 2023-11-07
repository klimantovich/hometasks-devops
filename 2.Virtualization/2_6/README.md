# Установка minikube & kubectl
minikube:  
```
vklimantovich@nt-admins-MacBook-Pro 2_6 % minikube version
minikube version: v1.31.2
commit: fd7ecd9c4599bef9f04c0986c4a0187f98a4396e
```
kubectl:  
```
vklimantovich@nt-admins-MacBook-Pro 2_6 % kubectl version
Client Version: v1.28.2
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
```

# Запуск Minikube & Проверка состояния кластера
```
vklimantovich@nt-admins-MacBook-Pro 2_6 % kubectl cluster-info
Kubernetes control plane is running at https://127.0.0.1:59548
CoreDNS is running at https://127.0.0.1:59548/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

# Создание и запуск пода
