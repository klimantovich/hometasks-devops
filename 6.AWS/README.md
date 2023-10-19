# PART 1
-----
## Создание VPC и подсетей

**VPC Resource map:**  
<img width="1122" alt="Снимок экрана 2023-10-17 в 12 44 27" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/f58caaa2-a512-4f5b-b8fc-f27ff9d4581e">

1. Создал VPC `hw-vpc`:
  - CIDR: 10.5.0.0/16
  - Region: Stocholm (eu-north-1)

2. В VPC воздал 3 подсети:
  - `hw-eu-north-1a-public-01` - CIDR 10.5.0.0/20, зона доступности eu-north-1a, публичная подсеть
  - `hw-eu-north-1a-private-01` - CIDR 10.5.32.0/20, зона eu-north-1a, приватная подсеть
  - `hw-eu-north-1b-public-02` - CIDR 10.5.16.0/20, зона eu-north-1b, публичная подсеть
<img width="1186" alt="Снимок экрана 2023-10-16 в 19 13 11" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/dc7941e5-ad0f-4769-89c2-71f9b7896712">

3. Создал 2 таблицы марштутизации для публичных и приватных подсетей
  - `hw-public-rt` - таблица для публичных сетей, весь трафик в другие сети направляем на gateway igw-046702b973d9fd443
<img width="872" alt="Снимок экрана 2023-10-17 в 12 49 27" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/9f2152b8-fa4c-42a7-a99e-a75fbbd513ec">

  - `hw-private-rt` - таблица для приватной сети, весь трафик в другие сети направляем направляем на NAT gateway
<img width="872" alt="Снимок экрана 2023-10-17 в 12 53 40" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/aaa85de2-24f9-45f8-a39b-e3e18c01238d">  

4. Создал 2 Network ACLs (для публичных и приватных подсетей). Для приватных подсетей запретил весь входящий трафик не из диапазона моей VPC.
<img width="1156" alt="Снимок экрана 2023-10-17 в 12 58 22" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/b0864ff7-17d4-4810-88bf-d75239a6cecd">

5. Создал 2 Security group (web-sg и db-sg). Для SG web-sg задал входящие правила: разрешил HTTP, HTTPS и SSH подключения с моего локального ip-адреса, и все подключения из моей VPC  
    <img width="604" alt="Снимок экрана 2023-10-17 в 13 01 30" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/458c6513-dc2a-42a4-b15f-5b627fc88c37">

## Создание EC2 инстансов и ELB

1. Генерирую RSA keypair:  
    <img width="598" alt="7" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/1a760dec-9505-43a3-a7ab-dcd6b2c065bf">
  
3. Запускаю инстансы (Launch instances) EC2 web-01 и web-02:
   - Image: `Amazon Linux`
   - Instance type: `t3.micro`
   - KeyPair Name: `vitali.keypair`
   - VPC: `hw-vpc`
   - Subnets: web-01 - `hw-eu-north-1a-public-01`, web-02 - `hw-eu-north-1b-public-02` # Создаем в разных available zones
   - Security Group: `web-sg`
<img width="1227" alt="Снимок экрана 2023-10-17 в 13 37 15" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/772740f6-7e8b-4017-b7bb-92b70563bacc">

4. Подключаюсь к инстансам и настраиваю nginx:
   ```
   ssh -i .ssh/vitali_keypair.pem ec2-user@ec2_ip_address
   sudo yum install nginx
   sudo systemctl enable nginx
   sudo systemctl start nginx
   ```
   Проверяю что по ip инстанса открывается веб-сервер:  
   <img width="957" alt="Снимок экрана 2023-10-17 в 13 56 30" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/1e39c315-9b50-4183-86b9-99096aae9ab7">
   Оба инстанса видят друг друга в сети, ping по private-ip адресу доходит. В то же время при смене ip (например включении vpn), веб-сервер не открывается и по ssh доступа на машину нет

5. Создаю Target Group `hw-targetgroup`:
   - Target type: `Instances`
   - Port: `80`
   - VPC: `hw-vpc`
   - Health check protocol: `HTTP`, path: `/`
   - Interval: `5 seconds`
   - Sucess codes: `200-399`
   Выбираю в aviable targets EC2 web-01 и web-02:
  <img width="1108" alt="Снимок экрана 2023-10-17 в 17 51 35" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/262b1778-7352-496b-b9a2-ae17719d5e9a">

6. Создаю Load Balancer `hw-elb`:
  - Type: `Application Load balancer`
  - Scheme: `Internet-facing`
  - VPC: `hw-vpc` / и маппим 2 public подсети - eun1-az1 & eun1-az2
  - Security Groups: `elb-sg` # Предварительно создал группу с открытым 80 портом наружу
  - Listener: `HTTP:80`, Target group: `hw-targetgroup` # Направляем трафик, поступающий на 80 порт балансера в созданную выше таргетгруппу
  <img width="1146" alt="Снимок экрана 2023-10-17 в 18 00 53" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/286d27bd-70b9-4cb1-931a-0b11294baf32">

7. Закрываем порты 80/443 EC2 инстансов c веб-сервером для всех, кроме Load Balancer'a. Для этого редактирую Security Group `web-sg`, в ней меняю Inbound rules (для HTTP/HTTPS выбираю source, который может по ним подключаться, секьюрити группу для load балансера `elb-sb`:
   <img width="1346" alt="Снимок экрана 2023-10-17 в 18 04 32" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/1802c4c3-785b-4435-aca5-935af7f84bf7">

8. Проверка работоспособности. Проверяю, что по ip инстансов nginx index.html не открыввается (т.к. теперь 80 порт закрыт для всех, кроме лоад балансера)  
   <img width="684" alt="Снимок экрана 2023-10-17 в 18 15 51" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/f69194aa-8a2c-4b96-8b95-54e9ca28f08e">  
   Останавливаем один из инстансов:  
   <img width="761" alt="Снимок экрана 2023-10-17 в 18 18 42" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/68a7d477-5244-40e4-8b46-ba4f6b0338e1">  
   Проверка работоспособности сейчас. При недоступности одного из инстансов, веб-сайт все равно работает.
   <img width="769" alt="Снимок экрана 2023-10-17 в 18 21 52" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/fbae580c-f8fc-4897-81fa-3d4f84cd5e73">

## Создание инстанса RDS

1. Так как для создания инстанса RDS нужно создать Subnet Group, включающий в себя 2 приватные сети в двух разных AZ, создал еще одну private subnet `hw-eu-north-1b-private-02` в AZ eu-north-1b. Добавил ее в таблицу маршрутизации `hw-private-rt` (как и у второй приватной сети). Теперь карта vpc выглядит так:
   <img width="1046" alt="Снимок экрана 2023-10-18 в 10 51 41" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/a19f79fa-217b-4e53-8c07-53254e92d93d">

2. Создал Subnet Group `hw-subnet-group-private`
   <img width="1107" alt="Снимок экрана 2023-10-18 в 10 54 41" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/0e875ead-ef7c-43b2-a833-b9690fcc7dfd">

3. Создал PDS инстанс со следующими параметрами:
   - Engine type: `PostgreSQL`
   - DB instance identifier: `hw-database-1`
   - DB instance class: `db.t3.micro`
   - Storage type: `General Purpose SSD (gp2)`, Allocated Size: `20 Gb`
   - VPC: `hw-vpc`, Subnet Group: `hw-subnet-group-private`, Public access: `no`
   - Security Group: `db-sg`
   <img width="942" alt="Снимок экрана 2023-10-18 в 11 02 39" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/df536e44-3c70-4ad4-aab1-0cf5a3e481ae">

4. Для Security Group `db-sg` создал входящее правило, разрешающее подключение по 5432 порту только для инстансов из секьюрити группы `web-sg`:
   <img width="1347" alt="Снимок экрана 2023-10-18 в 11 04 49" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/88e059dd-6fd9-4190-b105-7e6fce942580">

5. Проверка подключения к RDS postgreSQL с EC2 из web-sg группы:  
   Захожу на EC2 инстансы, Подключаюсь к удаленному postgres командой `psql -U postgres -p 5432 -h hw-database-1.cqju7juoavvm.eu-north-1.rds.amazonaws.com`. Мастер пароль использую тот, который указал на этапе создания RDS инстанса, hostname так же указываю хостнейм RDS инстанса.  
   *Подключение c инстанса web-01:*  
    <img width="786" alt="Снимок экрана 2023-10-18 в 11 41 38" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/fca4e0bf-f239-4750-9115-21401e6e3342">

    *Подключение c инстанса web-02:*   
    <img width="786" alt="Снимок экрана 2023-10-18 в 11 43 53" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/8e9f53c2-68cc-46a2-8c4c-954dcb66a6da">

## Создание инстансов ElastiCache

1. Создал 2 новых Security Groups, `cache-sg` (c inbound rule открытым портом 6582) для redis и `memcached-sg` (c inbound rule открытым портом 11211) для memcached. Подключение к инстансам будет доступно только из SG `web-sg`
  <img width="1157" alt="Снимок экрана 2023-10-18 в 12 43 37" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/9c0e015d-e85c-4de8-a087-85c2ff5c64a8">

2. Создал инстанс ElastiCache Redis `hw-redis-01` с параметрами:
   - Cluster mode: `Disabled`
   - Port: `6582`
   - Node type: `cache.t3.micro`
   - Subnet Group `hw-subnet-gr-01` (приватная c одной подсетью в eu-north-1a)
   - Security Group: `cache-sg`
   <img width="1305" alt="Снимок экрана 2023-10-18 в 12 53 43" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/e92a17b4-2034-43da-aa12-a79fe38c01ea">

3. Проверка подключения к redis с обоих инстансов EC2 (входящих в web-sg секьюрити группу). Предварительно установил redis-cli:  
   `redis-cli -c -h hw-redis-01-ro.ypbapl.ng.0001.eun1.cache.amazonaws.com -p 6581`
   <img width="859" alt="Снимок экрана 2023-10-18 в 12 57 07" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/01b51f7c-2877-4e9c-903e-244c23ad4a1b">

4. Создал инстанс ElastiCache Memcached `hw-memcached` с параметрами: 
   - Cluster mode: `Disabled`
   - Port: `11211`
   - Number of nodes: `1`
   - Node type: `cache.t3.micro`
   - Subnet Group `hw-subnet-gr-02` (приватная c одной подсетью в eu-north-1b)
   - Security Group: `memcached-sg` # c открытым 11211 портом для подключений web-sg инстансов

5. Проверка подключения к эндпоинту memcached с обоих инстансов EC2 (входящих в web-sg секьюрити группу):
   `telnet hw-memcached.ypbapl.cfg.eun1.cache.amazonaws.com 11211`  
   <img width="643" alt="Снимок экрана 2023-10-18 в 13 08 42" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/839ca56e-b937-4c60-bd1d-e30ad08ab4a6">


### Cloud Formation & S3 Bucket

2. Создал S3 Bucket `hw-bucket-01` со следующими параметрами:
   - Region: `eu-north-01`
   - Object Ownership: `ACLs disabled`
   - Bucket Versioning: `Disable`
  
3. Сгенерировал 100 файлов по 256 Kb:  
   `mkfile -n 256k ./shared/file{2..10}`
   И заполнил ими бакет S3:  
   `aws s3 sync ./shared s3://hw-bucket-01`  
   <img width="1399" alt="Снимок экрана 2023-10-18 в 21 42 32" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/5b11722d-86e8-4082-a667-38f3011021ff">

4. Установил lifecycle policy: через 30 дней отправляем в Glacier, через 180 - удаляем:  
   <img width="800" alt="Снимок экрана 2023-10-19 в 19 26 19" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/d2be94f2-56fb-4de0-af80-21f95a9a3935">

  
  




