#!/bin/bash

# Function to display error and exit
function display_error {
    echo "Error: $1"
    exit 1
}

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   display_error "This script must be run as root"
fi

# Get domain name input
read -p "Enter your domain name (e.g., example.com): " domain_name

# Install required packages
apt update || display_error "Failed to update package list"
apt install -y firewalld ipset unzip || display_error "Failed to install required packages"

# Download and extract Dynamic Portal files
mkdir -p /usr/src/
cd /usr/src/ || display_error "Failed to change directory to /usr/src/dynamicportal"
wget https://github.com/manish23k/vicidial-dynamicportal.git || display_error "Failed to download Dynamic Portal files"
unzip main.zip || display_error "Failed to extract Dynamic Portal files"
cd vicidial-dynamicportal || display_error "Failed to change directory to vicidial-dynamicportal-main"

# Copy Firewall zones, services, ipset rules
cd firewalld_201
cp -r zones /etc/firewalld/
cp -r ipsets /etc/firewalld/
cd ..
cp services/ /usr/lib/firewalld/

# Copy Dynamic Portal files to web folder
cp -r dynportal_201 /var/www/html/dynportal

# Copy ssl file to http config folder
cp vicidial-ssl.conf /etc/apache2/sites-enabled

cp vicidial.conf /etc/apache2/sites-enabled

# Edit vicidial-ssl.conf with SSL certificate and key
sed -i "s#/etc/letsencrypt/live/$domain_name/fullchain.pem#" /etc/apache2/sites-available/vicidial-ssl.conf
sed -i "s#/etc/letsencrypt/live/$domain_name/privkey.pem#" /etc/apache2/sites-available/vicidial-ssl.conf

# Add listen ports in Apache configuration
#echo "Listen 81" >> /etc/apache2/ports.conf
#echo "Listen 446" >> /etc/apache2/ports.conf
mv /etc/apache2/ports.conf /etc/apache2/ports.conf.bak
cp ports.conf /etc/apache2

sudo a2ensite vicidial.conf
sudo a2ensite vicidial-ssl.conf

# Copy VB-firewall script to bin and set permissions
cd usr_share_vicibox-firewall_201
cp VB-firewall.pl /usr/bin/
chmod +x /usr/bin/VB-firewall.pl

#Patch Commmands for VB-firewall
sed -i 's/badips/blackips/g' /usr/bin/VB-firewall
sed -i 's/badnets/blacknets/g' /usr/bin/VB-firewall
sed -i 's/viciblack/ViciBlack/g' /usr/bin/VB-firewall



mysql -e "use asterisk;  INSERT INTO `vicidial_ip_lists` (`ip_list_id`, `ip_list_name`, `active`, `user_group`) VALUES
('ViciWhite',	'ViciWhite',	'Y',	'ADMIN'),
('ViciBlack',	'ViciBlack',	'Y',	'ADMIN');

mysql -e "use asterisk; INSERT INTO `vicidial_ip_list_entries` (`ip_list_id`, `ip_address`) VALUES
('ViciWhite',	'110.227.253.25'),
('ViciWhite',	'103.240.35.46');

# Add cronjob entry to run VB-firewall every minute
(crontab -l 2>/dev/null; echo "* * * * * /usr/bin/VB-firewall.pl --white --dynamic --quiet") | crontab -
(crontab -l 2>/dev/null; echo "@reboot /usr/bin/VB-firewall.pl --white --dynamic --quiet") | crontab -

(crontab -l 2>/dev/null; echo "#Entry for ViciWhite and Dynamic Portal") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * /usr/bin/VB-firewall.pl --white --dynamic --quiet") | crontab -
(crontab -l 2>/dev/null; echo "@reboot /usr/bin/VB-firewall.pl --white --dynamic --quiet") | crontab -


(crontab -l 2>/dev/null; echo "#Entry for ViciBlack list") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * /usr/local/bin/VB-firewall.pl  --quiet") | crontab -
(crontab -l 2>/dev/null; echo "@reboot  /usr/local/bin/VB-firewall.pl --quiet") | crontab -


(crontab -l 2>/dev/null; echo "#Entry for voipbl blacklist") | crontab -
(crontab -l 2>/dev/null; echo "@reboot /usr/local/bin/VB-firewall.pl --voipbl --noblack --quiet") | crontab -
(crontab -l 2>/dev/null; echo "0 */6 * * * /usr/local/bin/VB-firewall.pl --voipbl --noblack --flush –quiet") | crontab -

Use this for cluster Setup put this in WEB Server or where you install dynportal
#/usr/bin/rsync -a  /tmp/*-tmp root@192.168.0.20:/tmp
#* * * * * /usr/bin/rsync -a  /tmp/*-tmp root@192.168.0.20:/tmp


echo "Vicidial Dynamic Portal setup completed successfully."
echo "Make sure to you have configure your IP in the Vicidial whitelist IP List." 
echo "if Yes then only enable and start firewalld, and also add certificate in /etc/apache2/site-enable/vicidial-ssl.conf if its not added."

# Restart Firewalld
#systemctl enable firewalld
#systemctl restart firewalld || display_error "Failed to restart Firewalld"
