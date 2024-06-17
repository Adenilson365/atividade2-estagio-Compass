#!/bin/bash
#!/bin/bash
set -o history

dir_install=/home/ec2-user/install
mkdir $dir_install

#Função coleta logs do processo de instalação

log (){
       local var=$(history | tail -n -2 | head -1)
        if [ $1 == 0 ]; then
        echo "success: $var" >> $dir_install/logInstalacao.log
else
echo "fail: $var" >> $dir_install/logInstalacao.log
        fi
}


#Processo de Instalação Docker e Docker compose
sudo yum update
sudo yum install docker -y
log $?
sudo systemctl start docker
log $?
sudo systemctl enable docker
log $?

sudo usermod -aG docker ec2-user
log $?
newgrp docker
log $?

sudo mkdir -p /usr/local/lib/docker/cli-plugins
log $?

sudo curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
log $?

sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
log $?

systemctl restart docker
log $?

#Montagem do EFS
sudo mkdir /efs
log $?

efs_dns=$(aws ssm get-parameter --name "dns_efs_parameter" --query "Parameter.Value" --output text --region us-east-1)
log $?

sudo chmod o+w /etc/fstab
log $?

echo "$efs_dns:/ /efs nfs4 nofail,_netdev,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport   0 0 " >> /etc/fstab
log $?

sudo mount -a
log $?

sudo chmod o-w /etc/fstab
log $?

#Preparação dos parametros para subir o container
alb_dns=$(aws ssm get-parameter --name "alb_dns" --query "Parameter.Value" --output text --region us-east-1)
rds_parameter=$(aws ssm get-parameter --name "rds_parameter" --query "Parameter.Value" --output text --region us-east-1)
log $?

db_host=$(echo $rds_parameter | cut -d"," -f1) 
log $?
db_user=$(echo $rds_parameter | cut -d"," -f2)
log $?
db_pass=$(echo $rds_parameter | cut -d"," -f3)
log $?
db_name=$(echo $rds_parameter | cut -d"," -f4)
log $?

echo "db_host=$db_host" >> $dir_install/.env
log $?
echo "db_user=$db_user" >> $dir_install/.env
log $?
echo "db_pass=$db_pass" >> $dir_install/.env
log $?
echo "db_name=$db_name" >> $dir_install/.env
log $?
echo "alb_dns=$alb_dns" >> $dir_install/.env
log $?

cat << EOF >> $dir_install/docker-compose.yml

services:
  wordpress:
    image: wordpress
    container_name: wp
    ports:
      - "80:80"
    volumes:
      - /efs/site:/var/www/html
    environment:
      WORDPRESS_DB_HOST: ${db_host}
      WORDPRESS_DB_USER: ${db_user}
      WORDPRESS_DB_PASSWORD: ${db_pass}
      WORDPRESS_DB_NAME: ${db_name}
      WORDPRESS_CONFIG_EXTRA: |
        define ("WP_HOME", "http://${alb_dns}");
        define ("WP_SITEURL", "http://${alb_dns}");
    restart: unless-stopped  
EOF

log $?

cd $dir_install
log $?

#Subir conteiner

docker compose up 
log $?
