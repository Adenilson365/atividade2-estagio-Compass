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

efs_dns=$(aws ssm get-parameter --name "parametro_ativ_2_efs" --query "Parameter.Value" --output text --region us-east-1)
log $?

sudo chmod o+w /etc/fstab
log $?

echo "$efs_dns /efs nfs4 nofail,_netdev,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport   0 0 " >> /etc/fstab
log $?

sudo mount -a
log $?

sudo chmod o-w /etc/fstab
log $?

#Preparação dos parametros para subir o container
access=$(aws ssm get-parameter --name "parametro_ativ_2_db" --query "Parameter.Value" --output text --region us-east-1)
log $?

db_host=$(echo $access | cut -d"," -f1) 
log $?
db_user=$(echo $access | cut -d"," -f2)
log $?
db_pass=$(echo $access | cut -d"," -f3)
log $?
db_name=$(echo $access | cut -d"," -f4)
log $?

echo "db_host=$db_host" >> $dir_install/.env
log $?
echo "db_user=$db_user" >> $dir_install/.env
log $?
echo "db_pass=$db_pass" >> $dir_install/.env
log $?
echo "db_name=$db_name" >> $dir_install/.env
log $?

cp /efs/compose/docker-compose.yml $dir_install
log $?

cd $dir_install
log $?

#Subir conteiner

docker compose up 
log $?
