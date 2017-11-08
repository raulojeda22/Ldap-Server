#!/bin/bash
echo "Incluyendo nueva tarjeta de red"
echo "auto enp0s8" >> /etc/network/interfaces
echo "iface enp0s8 inet static" >> /etc/network/interfaces
echo "  address 10.10.10.1" >> /etc/network/interfaces
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
