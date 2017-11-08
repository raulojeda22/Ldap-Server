serverHost2="\$servers->setValue('server','host','$newIp');"
serverBase2="\$servers->setValue('server','base',array('dc=$newDomain1,dc=$newDomain2'));"
serverLogin2="\$servers->setValue('login','bind_id','cd=$hostname,dc=$newDomain1,dc=$newDomain2');"
config2="// \$config->custom-appearence['hide_template_warning'] = true;"
sudo sed -i '/?>/d' config.php
sudo echo "$serverHost2
$serverBase2
$serverLogin2
$config2
?>" >> config.php