# vicidial-dynamicportal
https://www.striker24x7.com/2022/11/how-to-scratch-install-vicidial-dynamic-portal-in-centos.html


cp VB-firewall /usr/bin/

chmod +x /usr/bin/VB-firewall

cp -r zones /etc/firewalld/

cp vicidial-ssl.conf /etc/apache2/sites-available/
cp vicidial.conf /etc/apache2/sites-available

cd /servcies

cp *.xml /usr/lib/firewalld/services/

cp -r dynamicportal /var/www/html/
