#Setting new hostname
hostnewname=`cat ldap.txt | grep ^hostname | cut -d":" -f2`
sudo chmod 777 /etc/hostname
anteriorHostname=`hostname`
sudo echo "$hostnewname" > /etc/hostname #Açò canvia el hostname per sempre
sudo sed -i "s/$anteriorHostname/$hostnewname/g" /etc/hosts
echo "El teu nou hostname és $hostnewname."
hostnamectl set-hostname $hostnewname #Açò soles serà útil per a aquesta sessió, així no hem de reiniciar l'ordenador

sudo apt-get -y install slapd ldap-utils
newIp=`cat ldap.txt | grep ^ip | cut -d":" -f2`
newDomain1=`cat ldap.txt | grep ^domini | cut -d":" -f2 | cut -d"." -f1`
newDomain2=`cat ldap.txt | grep ^domini | cut -d":" -f2 | cut -d"." -f2`
sudo chmod 777 /etc/ldap/ldap.conf
echo "
BASE dc=$newDomain1,dc=$newDomain2
URI ldap://$newIp:389" >> /etc/ldap/ldap.conf
#gnome-terminal -e "bash -c ./instruccionsldap.sh;bash"
sudo dpkg-reconfigure slapd

sudo apt-get -y install phpldapadmin
sudo chmod 777 /etc/phpldapadmin/config.php 
serverHost="\$servers->setValue('server','host','$newIp');"
serverBase="\$servers->setValue('server','base',array('dc=$newDomain1,dc=$newDomain2'));"
serverLogin="\$servers->setValue('login','bind_id','cd=admin,dc=$newDomain1,dc=$newDomain2');"
config="// \$config->custom-appearence['hide_template_warning'] = true;"
sudo sed -i '/?>/d' /etc/phpldapadmin/config.php
sudo echo "$serverHost
$serverBase
$serverLogin
$config
?>" >> /etc/phpldapadmin/config.php

sudo systemctl restart apache2

#nmcli con show no mostra res en ubuntu server, alomillor hi ha que buscar altre comandament
#nmcli con mod "Connexions per xarxa amb fil 1" ipv4.addresses "192.168.100.1/24"
#phpldapadmin no funciona, però en realitat no importa, xP
#crea un fitxer ldif per a afegir els grups i usuaris

echo "Incluyendo nueva tarjeta de red"
echo "auto enp0s8" >> /etc/network/interfaces
echo "iface enp0s8 inet static" >> /etc/network/interfaces
echo "  address $newIP" >> /etc/network/interfaces
echo "  netmask 255.255.255.0" >> /etc/network/interfaces
echo "  dns-nameservers 172.27.111.5 172.16.99.119" >> /etc/network/interfaces
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "Reiniciando red"
/etc/init.d/networking restart

echo "Aplicando nuevas tablas de direccionamiento"
echo '#! /bin/bash

IPTABLES=/sbin/iptables

WANIF='enp0s3'
LANIF='enp0s8'

# enable ip forwarding in the kernel
echo 'Enabling Kernel IP forwarding...'
/bin/echo 1 > /proc/sys/net/ipv4/ip_forward

# flush rules and delete chains
echo 'Flushing rules and deleting existing chains...'
$IPTABLES -F
$IPTABLES -X

# enable masquerading to allow LAN internet access
echo 'Enabling IP Masquerading and other rules...'
$IPTABLES -t nat -A POSTROUTING -o $LANIF -j MASQUERADE
$IPTABLES -A FORWARD -i $LANIF -o $WANIF -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A FORWARD -i $WANIF -o $LANIF -j ACCEPT

$IPTABLES -t nat -A POSTROUTING -o $WANIF -j MASQUERADE
$IPTABLES -A FORWARD -i $WANIF -o $LANIF -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A FORWARD -i $LANIF -o $WANIF -j ACCEPT

echo 'Done.'' > scriptserver.sh

echo "Guardando el script para que se ejecute siempre que se inicie el ordenador"

sudo chmod 777 scriptserver.sh
sudo cp scriptserver.sh /etc/init.d/
cd /etc/init.d/
sudo update-rc.d scriptserver.sh defaults

echo "Reinicia el servidor para que los cambios tengan efecto"


