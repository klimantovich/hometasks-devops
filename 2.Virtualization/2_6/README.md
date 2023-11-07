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
Используемый image приложения: https://hub.docker.com/repository/docker/klim4ntovich/catnip/general  

Манифест пода: my-pod.yaml (Добавил readiness- & liviness- probes, проверка доступности порта приложения (5000) и самого веб-приложения)  
```
vklimantovich@nt-admins-MacBook-Pro 2_6 % kubectl create -f my-pod.yaml 
pod/web-app created
vklimantovich@nt-admins-MacBook-Pro 2_6 % kubectl get po
NAME      READY   STATUS              RESTARTS   AGE
web-app   0/1     ContainerCreating   0          5s
vklimantovich@nt-admins-MacBook-Pro 2_6 % kubectl get po
NAME      READY   STATUS    RESTARTS   AGE
web-app   1/1     Running   0          98s
```
Манифест сервиса: my-svc.yaml (Сделал ему type: LoadBalancer, чтоб сделать доступ к нему извне)
```
vklimantovich@nt-admins-MacBook-Pro 2_6 % kubectl create -f my-svc.yaml 
service/web-app-svc created
vklimantovich@nt-admins-MacBook-Pro 2_6 % kubectl get svc
NAME          TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes    ClusterIP      10.96.0.1       <none>        443/TCP        23m
web-app-svc   LoadBalancer   10.105.37.145   <pending>     80:31138/TCP   4s
```
Создаем туннель к сервису: minikube service web-app-svc и проверяем что все работает как надо:
<img width="651" alt="Снимок экрана 2023-11-07 в 22 32 13" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/0da998a9-353f-49b4-bb00-eed278eece07">  

# Журналы и отладка:
**kubectl describe pod web-app**
```
vklimantovich@nt-admins-MacBook-Pro 2_6 % kubectl describe pod/web-app 
Name:             web-app
Namespace:        default
Priority:         0
Service Account:  default
Node:             task/192.168.58.2
Start Time:       Tue, 07 Nov 2023 22:30:09 +0300
Labels:           app=catnip
Annotations:      <none>
Status:           Running
IP:               10.244.0.5
IPs:
  IP:  10.244.0.5
Containers:
  app:
    Container ID:   docker://7ba9f5b89d615f7b42d2dfa3b27851aaee2802377ac24371eced2f4c68a58eb1
    Image:          klim4ntovich/catnip
    Image ID:       docker-pullable://klim4ntovich/catnip@sha256:bdc330141fa0c7d4be8b8fbfa9fbdfb4cafa46d863af17d3e8c8cf18b6fb5ad4
    Port:           5000/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Tue, 07 Nov 2023 22:30:11 +0300
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  128Mi
    Requests:
      cpu:        500m
      memory:     128Mi
    Liveness:     http-get http://:5000/ delay=3s timeout=1s period=2s #success=1 #failure=3
    Readiness:    tcp-socket :5000 delay=5s timeout=1s period=10s #success=1 #failure=3
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-wcnlv (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-wcnlv:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Guaranteed
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  3m44s  default-scheduler  Successfully assigned default/web-app to task
  Normal  Pulling    3m44s  kubelet            Pulling image "klim4ntovich/catnip"
  Normal  Pulled     3m42s  kubelet            Successfully pulled image "klim4ntovich/catnip" in 1.863954136s (1.863998205s including waiting)
  Normal  Created    3m42s  kubelet            Created container app
  Normal  Started    3m42s  kubelet            Started container app
```
**kubectl logs web-app**
```
vklimantovich@nt-admins-MacBook-Pro 2_6 % kubectl logs web-app     
 * Serving Flask app "app" (lazy loading)
 * Environment: production
   WARNING: Do not use the development server in a production environment.
   Use a production WSGI server instead.
 * Debug mode: off
 * Running on all addresses.
   WARNING: This is a development server. Do not use it in a production deployment.
 * Running on http://10.244.0.5:5000/ (Press CTRL+C to quit)
10.244.0.1 - - [07/Nov/2023 19:30:15] "GET / HTTP/1.1" 200 -
10.244.0.1 - - [07/Nov/2023 19:30:17] "GET / HTTP/1.1" 200 -
10.244.0.1 - - [07/Nov/2023 19:30:19] "GET / HTTP/1.1" 200 -
10.244.0.1 - - [07/Nov/2023 19:30:21] "GET / HTTP/1.1" 200 -
10.244.0.1 - - [07/Nov/2023 19:30:23] "GET / HTTP/1.1" 200 -
10.244.0.1 - - [07/Nov/2023 19:30:25] "GET / HTTP/1.1" 200 -
10.244.0.1 - - [07/Nov/2023 19:30:27] "GET / HTTP/1.1" 200 -
10.244.0.1 - - [07/Nov/2023 19:30:29] "GET / HTTP/1.1" 200 -
10.244.0.1 - - [07/Nov/2023 19:30:31] "GET / HTTP/1.1" 200 -
```
# Остановка и удаление ресурсов & остановка minikube
```
vklimantovich@nt-admins-MacBook-Pro 2_6 % kubectl delete pod web-app 
pod "web-app" deleted
vklimantovich@nt-admins-MacBook-Pro 2_6 % kubectl delete svc web-app-svc 
service "web-app-svc" deleted
vklimantovich@nt-admins-MacBook-Pro 2_6 % minikube stop
✋  Узел "task" останавливается ...
🛑  Выключается "task" через SSH ...
🛑  Остановлено узлов: 1.
```



