#!/usr/bin/bash
#
# Add Apache VirtualHost For CentOS
# Apache 2.4.6
# By Huson 2018-07-27
#
clear
echo
echo "Add Apache VirtualHost For CentOS"
echo

dbrootname="xxxxxxxx"
dbrootpwd="xxxxxxxx"
dbname="abc"
mysqlusername="abc"
mysqlpwd="AbCd1234"
domains="www.abc.com"
domain="abc.com"
#domains="www.xxx.abc.com"
#domain="xxx.abc.com"
cur_dir=`pwd`
computer_name=`hostname`

# Make Sure Run As root
if [[ $EUID -ne 0 ]]; then
	echo "Error: Must Be Run As root!" 1>&2
	exit 1
fi

# Define Domain Name
#read -p "(Please input domains such as:www.example.com):" domains
#if [ "$domains" = "" ]; then
#	echo "You need input a domain."
#	exit 1
#fi
#domain=`echo $domains | awk '{print $1}'`
if [ -f "/etc/httpd/conf.d/$domain.conf" ]; then
	echo "$domain is exist!"
	exit 1
fi

# Create Database
#read -p "(Please input the database name to create):" dbname
#read -p "(Please input the database user name):" mysqlusername
#read -p "(Please set the password for mysql user $dbname):" mysqlpwd
/usr/bin/mysql -u$dbrootname -p$dbrootpwd <<EOF
CREATE DATABASE IF NOT EXISTS \`$dbname\`;
GRANT ALL PRIVILEGES ON \`$dbname\` . * TO '$mysqlusername'@'localhost' IDENTIFIED BY '$mysqlpwd';
GRANT ALL PRIVILEGES ON \`$dbname\` . * TO '$mysqlusername'@'127.0.0.1' IDENTIFIED BY '$mysqlpwd';
GRANT ALL PRIVILEGES ON \`$dbname\` . * TO '$mysqlusername'@'$computer_name' IDENTIFIED BY '$mysqlpwd';
GRANT ALL PRIVILEGES ON \`$dbname\` . * TO '$mysqlusername'@'::1' IDENTIFIED BY '$mysqlpwd';
FLUSH PRIVILEGES;
exit
EOF

# Define Website Dir
DocumentRoot="/data/www/$domain"
logsdir="$DocumentRoot_logs"
mkdir -p $DocumentRoot $logsdir
chown -R apache:apache $DocumentRoot
chown -R apache:apache $logsdir

# Create Vhost Configuration File
cat >/etc/httpd/conf.d/$domain.conf<<EOF
# Virtual Hosts Config File
# By Huson
<Virtualhost *:80>
	ServerName $domain
	ServerAlias $domains
	DocumentRoot "$DocumentRoot"
	ErrorLog "$logsdir/error.log"
	CustomLog "$logsdir/access.log" combined
	<Directory "$DocumentRoot">
		AllowOverride All
		Require all granted
	</Directory>
</Virtualhost>
EOF

systemctl restart httpd
echo
echo "Successfully Create $domain Vhost"
echo "The DocumentRoot:$DocumentRoot"
echo "Created DB Name: $dbname, DB User: $mysqlusername, Password:$mysqlpwd"
echo "DONE."
echo

#######################################################
# apache 2.2                                          #
# Order deny,allow                                    #
# Deny from all                                       #
# apache 2.4                                          #
# Require all denied                                  #
# #####################################################
# apache 2.2                                          #
# Order allow,deny                                    #
# Allow from all                                      #
# apache 2.4                                          #
# Require all granted                                 #
# #####################################################
# apache 2.2                                          #
# Order Deny,AllowDeny from allAllow from example.org #
# apache 2.4                                          #
# Require host example.org                            #
#######################################################
