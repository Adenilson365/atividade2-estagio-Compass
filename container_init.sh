#!/bin/bash

DockerPs=$(docker ps -a -q)

if [ -n $(echo $DockerPs | tr -d " ") ] 
then
   docker start $DockerPs
else
   exit 0
fi