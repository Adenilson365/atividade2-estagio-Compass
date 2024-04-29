#!/bin/bash

sudo yum update
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker



access=$(aws ssm get-parameter --name "parametro_ativ_2_db" --query "Parameter.Value" --output text --region us-east-1)
echo $access

db_host=$(echo $access | cut -d"," -f1) 
db_user=$(echo $access | cut -d"," -f2)
db_pass=$(echo $access | cut -d"," -f3)
db_name=$(echo $access | cut -d"," -f4)

docker run -dit --name wp -e WORDPRESS_DB_HOST=$db_host -e WORDPRESS_DB_USER=$db_user -e WORDPRESS_DB_PASSWORD=$db_pass -e WORDPRESS_DB_NAME=$db_name -p 80:80