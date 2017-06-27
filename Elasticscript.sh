#!/bin/bash
#Het updaten en upgraden van het systeem
echo "127.0.0.1 testminion" | sudo tee /etc/hosts
sudo apt update && upgrade -y

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
sudo sed -i '15s/.*/@10.8.0.28/' /etc/rsyslog.d/50-default.conf
sudo service rsyslog restart

#Formatting the Log Data to JSON
sudo wget -O 01-json-template.conf https://github.com/RedFoxNL/saltstack/blob/master/01-json-template.conf
sudo cp 01-json-template.conf /etc/rsyslog.d/01-json-template.conf

#Het toevoegen van het IP adress van de Logstash server
sudo sed -i '4s/.*/*.* @10.8.0.28:10514;json-template/' /etc/rsyslog.d/60-output.conf

#Het installeren van logstash
sudo wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo echo "deb http://packages.elastic.co/logstash/2.3/debian stable main" | sudo tee -a /etc/apt/sources.list
sudo apt update
sudo apt install logstash -y

#Het ophalen van de logstash.conf
sudo wget -O logstash.conf https://github.com/RedFoxNL/saltstack/blob/master/logstash.conf
sudo cp logstash.conf /etc/logstash/conf.d/logstash.conf
sudo service logstash configtest
sudo service logstash start
sudo service rsyslog restart
 

