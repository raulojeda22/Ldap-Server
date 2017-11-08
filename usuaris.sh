newDomain1=`cat ldap.txt | grep ^domini | cut -d":" -f2 | cut -d"." -f1`
newDomain2=`cat ldap.txt | grep ^domini | cut -d":" -f2 | cut -d"." -f2`
linia=`cat ldap.txt | grep -nr ^#Grups | cut -d":" -f2`
let linia=$linia+1
grupsUsuaris=`cat ldap.txt | tail -n+$linia`
grups=`echo "$grupsUsuaris" | cut -d":" -f1`
contadorGrups=2000
contadorUsuaris=3000
echo "dn: ou=People,dc=$newDomain1,dc=$newDomain2
objectClass: top
objectClass: organizationalUnit
ou:People

dn: ou=Group,dc=$newDomain1,dc=$newDomain2
objectClass: top
objectClass: organizationalUnit
ou: Group" > afegirGrupsiUsuaris.ldif
for grupActual in $grups
do
echo "
dn: cn=$grupActual,ou=Group,dc=$newDomain1,dc=$newDomain2
objectClass:top
objectClass:posixGroup
gidNumber:$contadorGrups
cn:$grupActual" >> afegirGrupsiUsuaris.ldif
usuaris=`echo "$grupsUsuaris" | grep ^$grupActual | cut -d":" -f2 | tr , " "`
for usuariActual in $usuaris
do
echo "
dn: uid=$usuariActual$grupActual,ou=People,dc=$newDomain1,dc=$newDomain2
objectClass: top
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: person
cn: $usuariActual
uid: $usuariActual
uidNumber: $contadorUsuaris
gidNumber: $contadorGrups
homeDirectory: /home/users/$usuariActual
loginShell: /bin/bash
userPassword: {crypt}x
sn: $usuariActual
mail: $usuariActual@$newDomain1.$newDomain2
givenName: $usuariActual" >> afegirGrupsiUsuaris.ldif

let contadorUsuaris=$contadorUsuaris+1
done
let contadorGrups=$contadorGrups+1
done
#ldapadd -x -D "cn=$hostnewname,dc=$newDomain1,dc=$newDomain2" -W -f afegirGrupsiUsuaris.ldif   
ldapadd -x -h localhost -D "cn=admin,dc=$newDomain1,dc=$newDomain2" -W -f afegirGrupsiUsuaris.ldif
# {SSHA}OcX/kW6K+XY69H8pP52ir8/2unMBjPPk
