# Atividade Docker Estágio Compass UOL

## Objetivo:

### Subir uma aplicação Wordpress usando Docker, consumindo RDS e persistindo arquivos em diretório (EFS).
  - A Aplicação deve estar atrás de um Elastic Load Balancer (ELB) e não ser acessível diretamente na 80/443 da EC2.
  - A aplicação deve estar atendida por um Auto Scaling.
  - A aplicação deve ser inicializada via script no user_data.

### Documentação
 - Itens 1 e 2 - Automatizado pelo script env_install.sh
 - Item 3 : Necessário realizar manualmente na primeira instalação, ou na alteração das configurações.
 - [Montagem EFS](#montagem-efs)
 - [Instalação Docker, Docker compose e RUN da Aplicação](#instala%C3%A7%C3%A3o-do-docker-docker-compose-e-run-do-cont%C3%AAiner)
 - [Configuração Wordpress](#configura%C3%A7%C3%A3o-wordpress)

### Montagem EFS
- Crie um diretório para organizar os artefatos gerados pelo script
  ```
  dir_install=/home/ec2-user/install
  mkdir $dir_install
  ```
- Dentro do EFS haverá duas pastas /site e /compose
  - /site : contém os arquivos do Wordpress, e será mapeada para dentro do contêiner
  - /compose : contém o arquivo docker-compose.yml
    
- Crie a pasta para o ponto de montagem do efs:
  ```
  sudo mkdir /efs
  ```
- Capture o parâmetro do efs do Parameter do Store 
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
### Instalação do Docker, Docker Compose e RUN do contêiner
- Instale apartir do gerenciador de pacotes (nesse caso yum) 
  ```
  sudo yum install docker -y
  ```
- Inície o serviço do Docker e Adicione a inicialização automática no boot
  ```
  sudo systemctl start docker
  sudo systemctl enable docker
  ```
- Adicione o usuário ec2-user ao grupo docker e atualize o grupo
  ```
  sudo usermod -aG docker ec2-user
  newgrp docker
  ```
- Crie o diretório cli-plugins  [Seguir Documentação Docker](https://docs.docker.com/compose/install/linux/) 
  ```
  sudo mkdir -p /usr/local/lib/docker/cli-plugins
  ```
- Baixe o binário do plugin compose
  ```
  sudo curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
  ```
- Dê permissão de execução
  ```
  sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
  ```
- Dê restart no docker
  ```
  systemctl restart docker
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
- Crie o arquivo .env na pasta de instalação criada no início
  ```
  echo "db_host=$db_host" >> $dir_install/.env
  echo "db_user=$db_user" >> $dir_install/.env
  echo "db_pass=$db_pass" >> $dir_install/.env
  echo "db_name=$db_name" >> $dir_install/.env
  ```
- Copie o docker-compose.yml para a pasta de instalação
  ```
  cp /efs/compose/docker-compose.yml $dir_install
  ```
- Navegue para a pasta, e execute o docker-compose
  ```
  cd $dir_install
  docker compose up 
  ```
### Caso não tenha subido a aplicação, verifique os logs que devem estar na mesma pasta de instalação.      
 
### Configuração Wordpress
  - Na primeira execução é necessário realizar a configuração do Wordpress
     - O Arquivo wp-config.php será configurado na inicialização do contêiner com as varáveis de ambiente passadas no docker run
     - No entanto é necessário definir WP_HOME e WP_SITEURL para o Wordpress responder atrás do ELB
     - Pode verificar essa variáveis com o comando:
       ```
       cat wp-config.php | grep "define" | grep "http"
       ´´´
      - Se houver configuração vai retornar um valor, caso contrário o default é o ip do servidor que instalou o Wordpress
      - Para configurar basta adicionar oa wp-config.php:
          ```
          define ("WP_HOME", "http://url_load_balancer");
          define ("WP_SITEURL","http://url_load_balancer"); 
          ```
       - Pode ser configurado no painel admin  em configurações/geral os campos Endereço Worpdress(URL) e Endereço do site(URL)
       - Caso não configure:
         - O ELB vai mandar sempre para o mesmo Servidor, se o servidor cair compromete a aplicação.
     - Configuração do usuário admin
       - No primeiro acesso, se as configurações até aqui estiverem corretas teremos:
          - Uma página para informar e-mail, usuário e senha forte para o painel de admin do Wordpress.