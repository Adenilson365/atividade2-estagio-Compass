# Atividade Docker Estágio Compass UOL

## Objetivo:

### Subir uma aplicação Wordpress usando Docker, consumindo RDS e compartilhando diretório (EFS).
  - A Aplicação deve estar atrás de um Elastic Load Balancer (ELB) e não ser acessível diretamente na EC2.
  - A aplicação deve estar atendida por um Auto Scaling permitindo a substuição automática de EC2.
  - A aplicação deve estar o mais automatizada possível.

### Documentação
 - [Montagem EFS](#montagem-efs)
 - [Instalação Docker](#instala%C3%A7%C3%A3o-do-docker-e-run-do-cont%C3%AAiner)
 - Subir Wordpress
 - Configuração Wordpress

### Montagem EFS
- Crie a pasta para o ponto de montagem:
  ```
  sudo mkdir /efs
  ```
- Capture o parâmetro do Parameter do Store 
  ```
   efs_dns=$(aws ssm get-parameter --name "parametro_ativ_2_efs" --query "Parameter.Value" --output text --region us-east-1)
  ```
- Forneça modo de escrita para os outros no /etc/fstab
  ```
  sudo chmod o+w /etc/fstab
  ```
- Adicione ao /etc/fstab configuração de montagem do efs
  ```
  echo "$efs_dns /efs nfs4 nofail,_netdev,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport   0 0 " >> /etc/fstab
  ```
- Monte apartir do /etc/fstab
  ```
  sudo mount -a
  ```
- Restaure as permissões do /etc/fstab
  ```
  sudo chmod o-w /etc/fstab
  ```
### Instalação do Docker e RUN do contêiner
- Instale apartir do gerenciador de pacotes (nesse caso yum) 
  ```
  sudo yum install docker -y
  ```
- Inície o serviço do Docker e Adicione a inicialização automática no boot
  ```
  sudo systemctl start docker
  sudo systemctl enable docker
  ```
- Capture os parâmetros do banco de dados e atribua a uma variável (nesse caso foi armazenado como stringlist no Parameter Store)
  ```
  access=$(aws ssm get-parameter --name "parametro_ativ_2_db" --query "Parameter.Value" --output text --region us-east-1)
  ```
- Individualize as variáveis de acesso
  ```
  db_host=$(echo $access | cut -d"," -f1) 
  db_user=$(echo $access | cut -d"," -f2)
  db_pass=$(echo $access | cut -d"," -f3)
  db_name=$(echo $access | cut -d"," -f4)
  ``` 
- Suba o contêiner com docker run
  ```
  sudo docker run -dit --name wp -e WORDPRESS_DB_HOST=$db_host -e WORDPRESS_DB_USER=$db_user -e WORDPRESS_DB_PASSWORD=$db_pass -e WORDPRESS_DB_NAME=$db_name -p 80:80 -v /efs/site:/var/www/html wordpress
  ```
  - tag -dit : executa o contêiner em segundo plano, iterativo, e com terminal
  - tag -e : insere as variáveis de ambientes necessárias ao contêiner de wordpress
  - tag -p : determina a porta que vai expor a aplicação dessa forma,  portaHost:portaContêiner
  - tag -v : Mapeia um volume para dentro do contêiner dessa forma, caminhoHost:caminhoContêiner