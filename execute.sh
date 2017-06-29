#!/bin/bash

#Het opvragen van IP adress en het zetten in de variabele IP
IP="$(/sbin/ip -o -4 addr list ens3 | awk '{print $4}' | cut -d/ -f1)"

#Het aanpassen van de hostname
HST="$(hostname)" 
sudo sed -i "/127.0.0.1/ a\127.0.0.1 $HST" /etc/hosts

#installeren van docker
sudo apt update -y && apt upgrade -y

#Het installeren van Curl
sudo apt install curl -y
sudo curl -fsSL https://get.docker.com/ | sh
sudo service docker restart

#Het aanmaken van de wordpress container
mkdir ~/wordpress && cd ~/wordpress

#Het clonen van MariaDB
sudo docker run -e MYSQL_ROOT_PASSWORD=Cisco123 -e MYSQL_DATABASE=wordpress --name wordpressdb -v "$PWD/database":/var/lib/mysql -d mariadb:latest

#Het koppelen en starten van de Wordpress container
sudo docker start wordpressdb

#Het ophalen van de Wordpress images
sudo docker pull wordpress

#Het aanmaken van de /var/www/html map
cd /var
sudo mkdir www
cd www
sudo mkdir html

#Het uitvoeren van Docker met de Wordpress container in de achtergrond
sudo docker run -e WORDPRESS_DB_PASSWORD=Cisco123 --name wordpress --link wordpressdb:mysql -p $IP:80:80 -v "$PWD/html":/var/www/html -d wordpress

#Het forwarden van het IP adres
sudo iptables -P FORWARD ACCEPT

#Het installeren van Elasticsearch
sudo apt install elasticsearch -y

#Het instellen van het IP van de Hoofd Syslog server
sudo sed -i '203s/.*/network.bind_host: 10.8.0.28/' /etc/elasticsearch/elasticsearch.yml
sudo service elasticsearch restart

#Het uncommenten van de UDP en TCP modules
sudo sed -i '18s/.*/module(load="imudp")/' /etc/rsyslog.conf
sudo sed -i '19s/.*/input(type="imudp" port="514")/' /etc/rsyslog.conf
sudo sed -i '22s/.*/module(load="imtcp")/' /etc/rsyslog.conf
sudo sed -i '23s/.*/input(type="imtcp" port="514")/' /etc/rsyslog.conf
sudo service rsyslog restart

#Het toevoegen van het IP van de server waarmee hij moet connecten
sudo sed -i '5s/.*/ *.*\		\@10.8.0.28:514/' /etc/rsyslog.d/50-default.conf
sudo service rsyslog restart

#Formatting the Log Data to JSON
sudo git clone https://github.com/RedFoxNL/saltstack.git
sudo cp saltstack/config/01-json-template.conf /etc/rsyslog.d/01-json-template.conf

#Het installeren van logstash
sudo wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo echo "deb http://packages.elastic.co/logstash/2.3/debian stable main" | sudo tee -a /etc/apt/sources.list
sudo apt update
sudo apt install logstash -y

#Het ophalen van de logstash.conf
sudo cp saltstack/config/logstash.conf /etc/logstash/conf.d/logstash.conf
sudo sed -i '26s/.*/hosts => [ "'$IP':9200" ]/' /etc/logstash/conf.d/logstash.conf
sudo service logstash configtest
sudo service logstash start
sudo service rsyslog restart

#Het starten van ElasticSearch
sudo /usr/share/elasticsearch/bin/elasticsearch start &
sudo rm -rf /home/ubuntu/saltstack

