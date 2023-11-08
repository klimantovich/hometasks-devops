# Установка Prometheus & Grafana с помощью helm charts
Prometheus helm chart: https://github.com/prometheus-community/helm-charts  
Grafana helm chart: https://grafana.github.io/helm-charts/  
установил с помощью helm install:  
```
vklimantovich@nt-admins-MacBook-Pro 10.Monitoring % kubectl get all
NAME                                                     READY   STATUS    RESTARTS   AGE
pod/grafana-75dd9f5d89-h9kjc                             1/1     Running   0          102m
pod/prometheus-alertmanager-0                            1/1     Running   0          106m
pod/prometheus-kube-state-metrics-56f5765bcf-qlw77       1/1     Running   0          106m
pod/prometheus-prometheus-node-exporter-p4bzr            1/1     Running   0          106m
pod/prometheus-prometheus-pushgateway-5b7b9f67bb-7mlx9   1/1     Running   0          106m
pod/prometheus-server-7bbd49dd-7jpwt                     2/2     Running   0          106m

NAME                                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/grafana                               ClusterIP   10.96.70.213     <none>        80/TCP     102m
service/kubernetes                            ClusterIP   10.96.0.1        <none>        443/TCP    126m
service/prometheus-alertmanager               ClusterIP   10.99.98.249     <none>        9093/TCP   106m
service/prometheus-alertmanager-headless      ClusterIP   None             <none>        9093/TCP   106m
service/prometheus-kube-state-metrics         ClusterIP   10.97.251.16     <none>        8080/TCP   106m
service/prometheus-prometheus-node-exporter   ClusterIP   10.98.227.79     <none>        9100/TCP   106m
service/prometheus-prometheus-pushgateway     ClusterIP   10.100.74.98     <none>        9091/TCP   106m
service/prometheus-server                     ClusterIP   10.100.238.246   <none>        80/TCP     106m

NAME                                                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/prometheus-prometheus-node-exporter   1         1         1       1            1           kubernetes.io/os=linux   106m

NAME                                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/grafana                             1/1     1            1           102m
deployment.apps/prometheus-kube-state-metrics       1/1     1            1           106m
deployment.apps/prometheus-prometheus-pushgateway   1/1     1            1           106m
deployment.apps/prometheus-server                   1/1     1            1           106m

NAME                                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/grafana-75dd9f5d89                             1         1         1       102m
replicaset.apps/prometheus-kube-state-metrics-56f5765bcf       1         1         1       106m
replicaset.apps/prometheus-prometheus-pushgateway-5b7b9f67bb   1         1         1       106m
replicaset.apps/prometheus-server-7bbd49dd                     1         1         1       106m

NAME                                       READY   AGE
statefulset.apps/prometheus-alertmanager   1/1     106m
```
# Создание Дашборда в Grafana

С помощью команды `minikube service <service_name>` можем создать туннель и подключиться к нужному сервису.  
Grafana:  
<img width="476" alt="Снимок экрана 2023-10-30 в 18 46 28" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/1ffafa7a-4f19-4c25-93cd-88f2b9c4a736">

Создание датасурса прометеуса в графане:  
<img width="371" alt="Снимок экрана 2023-10-30 в 18 47 55" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/8917861b-aa3b-4c9f-87c2-204b23865ce0">
<img width="1200" alt="Снимок экрана 2023-10-30 в 18 49 49" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/dd121d21-0f46-4036-8a29-c5832f6cdfbf">

Создал дашборд, который содержит панели:
- HTTP Requests total //метрика: prometheus_http_requests_total{})
- Pods Running //метрика: sum(kube_pod_status_phase{phase="Running"})
- Pods Failed //метрика: sum(kube_pod_status_phase{phase="Failed"})
- Pods Restarts //метрика: increase(kube_pod_container_status_restarts_total[5m])

  
