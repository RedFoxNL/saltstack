#!/bin/bash

#installeren van docker
sudo apt update -y && apt upgrade -y
sudo apt install curl -y
sudo curl -fsSL https://get.docker.com/ | sh
sudo service docker restart
mkdir ~/wordpress && cd ~/wordpress
sudo docker run -e MYSQL_ROOT_PASSWORD=Cisco123 -e MYSQL_DATABASE=wordpress --name wordpressdb -v "$PWD/database":/var/lib/mysql -d mariadb:latest
sudo docker start wordpressdb
sudo docker pull wordpress
cd /var
sudo mkdir www
cd www
sudo mkdir html
sudo docker run -e WORDPRESS_DB_PASSWORD=Cisco123 --name wordpress --link wordpressdb:mysql -p 127.0.0.1:80:80 -v "$PWD/html":/var/www/html -d wordpress

#installeren van DB

#installeren van wordpress

#het uitvoeren van de script Elasticsearch

