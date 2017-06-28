#!/bin/bash

#Het updaten en upgraden van het systeem
HST="$(hostname)" 
sudo sed -i "/127.0.0.1/ a\127.0.0.1 $HST" /etc/hosts
sudo apt update && upgrade -y

#Het installeren van de Salt-Minion
sudo apt-get install salt-minion -y

sudo git clone https://github.com/RedFoxNL/saltstack.git 
sudo cp -f saltstack/satl-minion /etc/salt
sudo salt-minion -d
