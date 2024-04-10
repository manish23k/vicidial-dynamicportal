# vicidial-dynamic portal Debian 11
https://manishkadiya.blogspot.com/2024/04/debian-11-vicidial-scratch-install.html


cp VB-firewall /usr/bin/

chmod +x /usr/bin/VB-firewall

cp -r zones /etc/firewalld/

cp vicidial-ssl.conf /etc/apache2/sites-available/

cp vicidial.conf /etc/apache2/sites-available

cd /servcies

cp *.xml /usr/lib/firewalld/services/

cp -r dynamicportal /var/www/html/


##### TO DELETE IP FROM SYSTEM####

ipset del dynamiclist 192.168.0.22
DELETE FROM `vicidial_user_log`
WHERE ((`computer_ip` = '110.227.253.25'));
