#!/usr/bin/env bash
#
# Yum Install LAMP ( Linux + Apache + MySQL + PHP )
# System Required: CentOS 6+
# By Huson 2018-07-24
#
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear

echo
echo "LAMP Auto Install For CentOS"
echo
cur_dir=`pwd`
dbrootname="xxxxxxxx"
dbrootpwd="xxxxxxxx"

# Make Sure Run As root
rootness(){
	if [[ $EUID -ne 0 ]]; then
		echo "Error: Must Be Run As root!" 1>&2
		exit 1
	fi
}

# Disable selinux
disable_selinux(){
	if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
		setenforce 0
	fi
}

pre_set(){
	# Create Users (no need)
#	groupadd apache
#	useradd -s /sbin/nologin -M -g apache apache
#	groupadd mysql
#	useradd -s /sbin/nologin -M -g mysql mysql
	# Remove Packages
	yum -y remove httpd*
	yum -y remove mysql*
	yum -y remove mariadb*
	yum -y remove php*
}

# Install Apache
install_apache(){
	# Install Apache
	echo "Start Installing Apache..."
	yum -y install httpd httpd-devel
	wget https://raw.githubusercontent.com/0x01-0xff/CloudSetup/master/InstallLAMP/conf/httpd.conf
	cp -f $cur_dir/httpd.conf /etc/httpd/conf/httpd.conf
	rm -fv /etc/httpd/conf.d/welcome.conf /data/www/error/noindex.html
	chkconfig httpd on
	mkdir -p /data/www/default
	chown -R apache:apache /data/www/default
	touch /data/www/default/myphpinfo.php
	cat >/data/www/default/myphpinfo.php<<EOF
<?php
phpinfo();
?>
EOF
	echo "Apache Install completed!"
}

# Install MySQL
install_mysql(){
	# Install MySQL
	echo "Start Installing MySQL..."
	rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
	yum -y install mysql mysql-server mysql-libs
	cp -f /usr/lib/systemd/system/mysqld.service /etc/init.d/mysqld
	cp -f /usr/lib/systemd/system/mysqld.service /etc/systemd/system/mysqld.service
	wget https://raw.githubusercontent.com/0x01-0xff/CloudSetup/master/InstallLAMP/conf/my.cnf
	cp -f $cur_dir/my.cnf /etc/my.cnf
	chkconfig mysqld on
	# Start mysqld service
	service mysqld start
	/usr/bin/mysqladmin password $dbrootpwd
	/usr/bin/mysql -uroot -p$dbrootpwd <<EOF
drop database if exists test;
delete from mysql.user where user='';
update mysql.user set password=password('$dbrootpwd') where user='root';
delete from mysql.user where not (user='root');
update mysql.user set user='$dbrootname' where user='root';
flush privileges;
exit
EOF
	echo "MySQL Install completed!"
}

# Install PHP
install_php(){
	echo "Start Installing PHP 7.1 ..."
	yum -y install libjpeg-devel libpng-devel
	yum -y install php71w-common php71w-fpm php71w-opcache php71w-gd php71w-mysqlnd php71w-mbstring php71w-pecl-redis php71w-pecl-memcached php71w-devel mod_php71w
	echo "PHP install completed!"
}

# Install phpMyAdmin.
install_phpmyadmin(){
    if [ ! -d /data/www/phpmyadmin ];then
		echo "Start Installing phpMyAdmin..."
		LATEST_PMA=$(wget --no-check-certificate -qO- https://www.phpmyadmin.net/files/ | awk -F\> '/\/files\//{print $3}' | cut -d'<' -f1 | sort -V | tail -1)
		if [[ -z $LATEST_PMA ]]; then
			LATEST_PMA=$(wget -qO- http://dl.lamp.sh/pmalist.txt | tail -1 | awk -F- '{print $2}')
		fi
		echo -e "Installing phpmyadmin version: \033[41;37m $LATEST_PMA \033[0m"
		cd $cur_dir
		if [ -s phpMyAdmin-${LATEST_PMA}-all-languages.tar.gz ]; then
			echo "phpMyAdmin-${LATEST_PMA}-all-languages.tar.gz [found]"
		else
			wget -c http://files.phpmyadmin.net/phpMyAdmin/${LATEST_PMA}/phpMyAdmin-${LATEST_PMA}-all-languages.tar.gz
			tar zxf phpMyAdmin-${LATEST_PMA}-all-languages.tar.gz
		fi
		mv phpMyAdmin-${LATEST_PMA}-all-languages /data/www/phpmyadmin
		wget https://raw.githubusercontent.com/0x01-0xff/CloudSetup/master/InstallLAMP/conf/config.inc.php
		cp -f $cur_dir/conf/config.inc.php /data/www/phpmyadmin/config.inc.php
		# Create phpmyadmin database
		/usr/bin/mysql -u$dbrootname -p$dbrootpwd </data/www/phpmyadmin/sql/create_tables.sql
		mkdir -p /data/www/phpmyadmin/upload/
		mkdir -p /data/www/phpmyadmin/save/
		cp -f /data/www/phpmyadmin/sql/create_tables.sql /data/www/phpmyadmin/upload/
		chown -R apache:apache /data/www/phpmyadmin
		rm -f phpMyAdmin-${LATEST_PMA}-all-languages.tar.gz
		echo "phpMyAdmin Install completed!"
	else
		echo "phpMyAdmin had been installed!"
	fi
	# Start httpd service
	service httpd start
}


# Install LAMP
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
rootness
disable_selinux
pre_set
install_apache
install_mysql
install_php
install_phpmyadmin

echo
echo "DONE."
echo "Enjoy it! "
echo
