# PART 1
-----
# Создание VPC и подсетей
**VPC Resource map:**  
<img width="1063" alt="Снимок экрана 2023-10-16 в 19 02 10" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/daa84572-3291-420a-8b39-54a0054f8b31">
1. Создал VPC `hw-vpc`:
  - CIDR: 10.5.0.0/16
  - Region: Stocholm (eu-north-1)
В нем создал 3 VPC:
2. В VPC воздал 3 подсети:
  - `hw-eu-north-1a-public-01` - CIDR 10.5.0.0/20, зона доступности eu-north-1a, публичная подсеть
  - `hw-eu-north-1a-private-01` - CIDR 10.5.32.0/20, зона eu-north-1a, приватная подсеть
  - `hw-eu-north-1b-public-02` - CIDR 10.5.16.0/20, зона eu-north-1b, публичная подсеть
<img width="1186" alt="Снимок экрана 2023-10-16 в 19 13 11" src="https://github.com/klimantovich/hometasks-devops/assets/91698270/dc7941e5-ad0f-4769-89c2-71f9b7896712">
3. Создал 2 таблицы марштутизации для публичных и приватных подсетей
