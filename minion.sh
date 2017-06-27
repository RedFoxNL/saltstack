#!bin/bash


#Het meegeven van een hostname
hostname='127.0.0.1 master'
echo $hostname >/etc/hosts

#Het updaten en upgraden van het werkstation
apt update -y && apt upgrade -y

#Het installeren van de Salt-minio
apt install salt-minion -y

#Het installeren van Curl
apt install curl -y

#Het ophalen van de scripts
wget -o scripts.sh https://github.com/RedFoxNL/saltstack/script.sh


