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





  




