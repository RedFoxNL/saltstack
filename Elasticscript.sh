#!bin/bash
#Het updaten en upgraden van het systeem
apt update && upgrade -y

#Het installeren van Elasticsearch
apt install elasticsearch -y

#Het instellen van het IP van de Hoofd Syslog server
sed -i '203s/.*/network.bind_host: 10.8.0.28/' /etc/elasticsearch/elasticsearch.yml
service elasticsearch restart

#Het uncommenten van de UDP en TCP modules
sed -i '18s/.*/module(load="imudp")/' /etc/rsyslog.conf
sed -i '19s/.*/input(type="imudp" port="514")/' /etc/rsyslog.conf
sed -i '22s/.*/module(load="imtcp")/' /etc/rsyslog.conf
sed -i '23s/.*/input(type="imtcp" port="514")/' /etc/rsyslog.conf
service rsyslog restart

#Het toevoegen van het IP van de server waarmee hij moet connecten
sed "15i @10.8.0.28" /etc/rsyslog.d/50-default.conf
service rsyslog restart

#Formatting the Log Data to JSON
wget -O 01-json-template.conf https://github.com/RedFoxNL/saltstack/blob/master/01-json-template.conf
cp 01-json-template.conf /etc/rsyslog.d/01-json-template.conf

#Het toevoegen van het IP adress van de Logstash server
sed -i '4s/.*/*.*                         @10.8.0.28:10514;json-template' /etc/rsyslog.d/60-output.conf

#Het installeren van logstash
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elastic.co/logstash/2.3/debian stable main" | sudo tee -a /etc/apt/sources.list
apt update
apt install logstash -y

#Het ophalen van de logstash.conf
wget -O logstash.conf https://github.com/RedFoxNL/saltstack/blob/master/logstash.conf
cp logstash.conf /etc/logstash/conf.d/logstash.conf
service logstash configtest
service logstash start
service rsyslog restart
 

