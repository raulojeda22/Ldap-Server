#!/bin/bash
onEstic=`pwd`
myIP=`ifconfig enp0s3 | grep "inet addr:" | cut -d" " -f12 | cut -d":" -f2`
echo -n "Original Server IP: "
read originalIP
echo -n "Your user name: "
read replicaUser
echo -n "Original Server User: "
read userName
ssh -t $userName@$originalIP sudo /etc/init.d/slapd stop
#ssh -t $userName@$originalIP touch backup-ldap.ldif
#ssh -t $userName@$originalIP sudo slapcat > backup-ldap.ldif
ssh -t $userName@$originalIP sudo scp backup-ldap.ldif $replicaUser@$myIP:$onEstic
ssh -t $userName@$originalIP sudo /etc/init.d/slapd start
sudo chmod 777 backup-ldap.ldif
sudo /etc/init.d/slapd stop
sudo slapadd -v -c -l backup-ldap.ldif
sudo slapindex -vF /etc/ldap/slapd.d
sudo /etc/init.d/slapd start