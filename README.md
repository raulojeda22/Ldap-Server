# Ldap-Server
Crear servidor Ldap

Per a crear servidor LDAP

Crear una màquina virtual de Ubuntu Server en VirtualBox.

Configurar la màquina (Paràmetres -> Xarxa) amb dues targetes de xarxa, Adaptador pont i Xarxa Interna.

Instalar Ubuntu Server Xenial i iniciar la màquina virtual.

Instalar el paquet git (sudo apt-get install git).

Baixar el repositori Ldap-Server (git clone https://github.com/raulojeda22/Ldap-Server.git).
Introdueix els següents comandaments:
$ cd Ldap-Server
$ chmod 777 *
$ sudo ./ldap.sh
¿Desea omitir la configuración del servidor LDAP? No 
Introduzca su nombre de dominio DNS: sox.com
Nombre de la organización: ldapserver
Motor de base de datos a utilizar: MDB
¿Desea que se borre la base de datos cuando se purgue el paquete slapd? No
¿Desea mover la base de datos antigua? Sí
¿Desea permitir el protocolo LDAPv2? No
Reinicia la màquina.
Introdueix el comando: $ ./usuaris.sh



Per a crear client LDAP
Crear una màquina virtual de Ubuntu Client en VirtualBox.
Configurar la màquina (Paràmetres -> Xarxa) amb una targeta de xarxa, Xarxa interna.
Edita les connexions/paràmetres IPv4
Adreça        Màscara de xarxa    Passarel·la
192.168.100.2    255.255.255.0        192.168.100.1
DNS: 172.27.111.5
Reiniciar. Comprobar la connexió a internet.
$ sudo su -
$ apt-get install ldap-auth-client nscd
ldap://192.168.100.1:389
dc=sox,dc=com
version 3
Make local root Database admin: <SÍ>
cn=admin,dc=sox,dc=com
$ auth-client-config -t nss -p lac_ldap
$ nano /usr/share/pam-configs/mkhomedir
Name: activate mkhomedir
Default: yes
Priority: 900
Session-Type: Additional
Session:
required    pam_mkhomedir.so umask=022 skel=/etc/skel
$ pam-auth-update
[*] activate mkhomedir
$ nano /etc/nsswitch.conf
passwd: compat ldap
group compat ldap
shadow: compat ldap
#…#
netgroup: ldap
$ /etc/init.d/nscd restart
$ getent passwd
$ nano /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
Afegís la línea:
greeter-show-manual-login=true



Backup del servidor
Crear servidor ldap com en aquesta documentació però:
Abans d’executar ldap.sh canvia el valor de la IP en ldap.txt (192.168.100.3)
No executes usuaris.sh
Instal·la el paquet openssh-server en les dos màquines servidor.
$ sudo apt-get install openssh-server
Estableix una conexió entre elles per a intercanviar-se les claus públiques i poder executar el comandament ssh i scp desde un script.
Executa `$ sudo slapcat > backup-ldap.ldif` en el home del servidor primari.    
$ git clone https://github.com/raulojeda22/Ldap-Server.git
$ cd Ldap-Server
$ chmod 777 *
$ sudo ./backup.sh



Replication del Servidor en el Proveïdor
$ nano provider_sync.ldif
Modifica la línea olcRootDN: cn=admin,dc=sox,dc=com
Crear directori:
$ sudo -u openldap mkdir /var/lib/ldap/accesslog
Afegir el nou contingut
$ sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// -f provider_sync.ldif



Replication Servidor Consumidor
Assegurar que la base de dades és idèntica a la del proveïdor
Modifica l’arxiu consumer_sync.ldif del git
provider (provider server’s hostname -- ldap01.example.com in this example -- or IP address)
binddn (the admin DN password you’re using)
credentials (the admin DN password you’re using)
searchbase (the database suffix you’re using)
olcUpdateRef(Provider server’s hostname or IP address)
rid (Replica ID, an unique 3-digit that identifies the replica. Each consumer should have at least one rid)
Afegeix el nou contingut.
$ sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// -f consumer_sync.ldif



Prova la rèplica
$ ldapsearch -z1 -LLLQY EXTERNAL -H ldapi:/// -s base -b dc=sox,dc=com contextCSN



Per a reiniciar una base de dades
$ sudo apt-get purge slapd ldap-utils
$ sudo apt-get install slapd ldap-utils
$ sudo dpkg-reconfigure slapd
$ ldapsearch -x-LLL -b dc=sox,dc=com cn



Samba and Ldap
$ sudo apt-get install samba smbldap-tools
$ zcat /usr/share/doc/samba/examples/LDAP/samba.ldif.gz | sudo ldapadd -Q -Y EXTERNAL -H ldapi:///
$ sudo ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b cn=schema,cn=config ‘cn=*samba*’ #Raül sha quedat ací
$ git clone https://github.com/raulojeda22/Ldap-Server.git
$ cd Ldap-Server
$ sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f samba_indices.ldif
Si tot ha anat bé, deuries vore els nous índexs utilitzant ldapsearch
$ sudo ldapsearch -Q -LLL -Y EXTERNAL -H \ ldapi:/// -b cn=config olcDatabase={1}mdb olcDbindex    
Configura smbldap-tools per a ser igual que el teu Ldap:
$ sudo smbldap-config
Samba Config File Location [] > /dev/null
smbldap Config file Location (global parameters) [/etc/smbldap-tools/smbldap.conf] > [Enter]
smbldap Config file Location (bind parameters) [/etc/smbldap-tools/smbldap_bind.conf] > [Enter]
  workgroup name [] > LDAPGROUP
  netbios name [] > LDAPNET
  logon drive [] > [Enter]
  logon home (press the "." character if you don't want homeDirectory) [\\EXAMPLE\%U] > [Enter]
  logon path (press the "." character if you don't want roaming profile) [\\EXAMPLE\profiles\%U] > [Enter]
. home directory prefix (use %U as username) [/home/%U] > [Enter]
. default users' homeDirectory mode [700] > [Enter]
. default user netlogon script (use %U as username) [] > [Enter]
  default password validation time (time in days) [45] > [Enter]
. ldap suffix [ldapsuffix] > dc=sox,dc=com
. ldap group suffix [ldapgroupsuffix] > ou=Group
. ldap user suffix [ldapusersuffix] > ou=People
. ldap machine suffix [ldapmachinesuffix] > ou=Computers
. Idmap suffix [ou=Idmap] > [Enter]
  sambaUnixIdPooldn object (relative to ${suffix}) [sambaDomainName=EXAMPLE] > [Enter]
. ldap master server [127.0.0.1] > [Enter]
. ldap master port [389] > [Enter]
. ldap master bind dn [] > cn=admin,dc=sox,dc=com
. ldap master bind password [] > [input your plain secret for Master LDAP Server]
  ldap slave server [127.0.0.1] >192.168.100.3
. ldap slave port [389] > [Enter]
. ldap slave bind dn [] > cn=admin,dc=sox,dc=com
. ldap slave bind password [] > [input your plain secret for Slave LDAP Server]
. ldap tls support (1/0) [0] >
  SID for domain MYGROUP [S-1-5-XX-XXXXXXXXXX-XXXXXXXXXX-XXXXXXXXXX] > [Enter]
  unix password encryption (CRYPT, MD5, SMD5, SSHA, SHA) [SSHA] > [Enter]
. default user gidNumber [513] > [Enter]
. default computer gidNumber [515] > [Enter]
. default login shell [/bin/bash] > [Enter]
. default domain name to append to mail adress [] > gmail.com

Fes un backup per si de cas abans de omplir el samba
$ sudo slapcat -l backup.ldif
Ompli el Samba
$ sudo smbldap-populate -g 10000 -u 10000 -r 10000



Configura Samba
Edita /etc/samba/smb.conf. Canvia la línea Workgroup per el teu grup i afegís baix aquests paràmetres.
workgroup=LDAPGROUP
#LDAP Settings
passdb backend = ldapsam:ldap//ldapserver
ldap suffix = dc=sox,dc=com
ldap user suffix = ou=People
ldap group suffix = ou=Group
ldap machine suffix = ou=Computers
ldap idmap suffix = ou=Idmap
ldap admin dn = cn=admin,dc=sox,dc=com
ldap passwd sync = yes
$ sudo smbpasswd -W
Comprova que el Samba funciona fent el comandament `$ getent group` en el client.
