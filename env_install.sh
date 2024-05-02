#!/bin/bash
set -o history

log (){
        local var=$(history | tail -n -2 | head -1)
        if [ $1 == 0 ]; then
        echo "success:[$1] $var" >> /home/ec2-user/logInstalacao.log
else
echo "fail[$1]: $var" >> /home/ec2-user/logInstalacao.log
        fi
}

sudo yum update
sudo yum install docker -y
log $?
sudo systemctl start docker
log $?
sudo systemctl enable docker
log $?

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

sudo docker run -dit --name wp -e WORDPRESS_DB_HOST=$db_host -e WORDPRESS_DB_USER=$db_user -e WORDPRESS_DB_PASSWORD=$db_pass -e WORDPRESS_DB_NAME=$db_name -p 80:80 -v /efs/site:/var/www/html wordpress
log $?