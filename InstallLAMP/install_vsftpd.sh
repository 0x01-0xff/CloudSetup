#!/bin/bash
#
# Install Vsftpd
# By Huson 2018-07-27
#
clear
echo
echo "Install Vsftpd"
echo

ftpusername="xxx"
ftpuserpw="xxxxxxxx"
webhome="/data/www/xxx"

cur_dir=`pwd`
# Make Sure Run As root
if [[ $EUID -ne 0 ]]; then
	echo "Error: Must Be Run As root!" 1>&2
	exit 1
fi

# Install
yum -y install vsftpd

# Create ftp user
useradd -s /sbin/nologin -d $webhome -M -g apache $ftpusername
echo $ftpuserpw |passwd --stdin $ftpusername
# Clear /etc/vsftpd/user_list and add ftpusername
echo $ftpusername >/etc/vsftpd/user_list
#echo $ftpusername >>/etc/vsftpd/user_list
#useradd -s /sbin/nologin -d $webhome -M -g ftp $ftpusername
#usermod -aG apache $ftpusername
#gpasswd -a $ftpusername apache

# SSL Support
openssl req -x509 -nodes -days 3650 -newkey rsa:1024 -subj "/C=CN/ST=GD/L=SZ/O=Huson/CN=Huson" -keyout /etc/vsftpd/hvsftpd.pem -out /etc/vsftpd/hvsftpd.pem

# Config File
wget https://raw.githubusercontent.com/0x01-0xff/CloudSetup/master/InstallLAMP/conf/vsftpd.conf
if [ -f "/etc/vsftpd/vsftpd.conf.bak" ]; then
	mv -f $cur_dir/vsftpd.conf /etc/vsftpd/vsftpd.conf
else
	mv /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
	mv -f $cur_dir/vsftpd.conf /etc/vsftpd/vsftpd.conf
fi

mkdir -p /data/www/vsftpd_logs
chown -R apache:apache /data/www
chmod -R 774 /data/www

# Service Start
systemctl enable vsftpd
systemctl start vsftpd

echo
echo "DONE."
echo
