newDomain1=`cat ldap.txt | grep ^domini | cut -d":" -f2 | cut -d"." -f1`
newDomain2=`cat ldap.txt | grep ^domini | cut -d":" -f2 | cut -d"." -f2`
echo "Instruccions:
¿Desea omitir...? <No>
DNS: $newDomain1.$newDomain2
Nombre organización: $newDomain1.$newDomain2
Motor de base de datos: HDB
Borre base de datos: <No>
Mover base de datos antigua: <Sí>
Protocolo ldapv2: <No>"