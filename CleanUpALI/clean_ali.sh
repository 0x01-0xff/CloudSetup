#!/bin/bash
#
# Ali Cloud Clean Up
# System Required: CentOS
# By Huson 2018-07-22
#
clear
# Make Sure Run As root
if [[ $EUID -ne 0 ]]; then
	echo "Error: Must Be Run As root!" 1>&2
	exit 1
fi
echo
echo "Ali Cloud Clean Up"
echo "For CentOS 7+"
echo

rm -rf /etc/yum.repos.d/
rpm -Uvh --force https://raw.githubusercontent.com/0x01-0xff/CloudSetup/master/CleanUpALI/epel-release/centos-release.rpm --quiet
echo
echo "-------------------------------------------------"
echo "YUM source initialized to CentOS 7 default [OK] +"
echo "-------------------------------------------------"
echo
rpm -Uvh --force https://raw.githubusercontent.com/0x01-0xff/CloudSetup/master/CleanUpALI/epel-release/epel-release-latest-7.noarch.rpm --quiet
#yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm --quiet
yum clean all
yum makecache
yum repolist
yum update -y
yum install vim curl wget -y
lsb_release -a
echo
echo "----------------------------------"
echo "Update system to the latest [OK] +"
echo "----------------------------------"
echo
curl -sSL https://raw.githubusercontent.com/0x01-0xff/CloudSetup/master/CleanUpALI/aegis_uninstall/quartz_uninstall.sh | bash
curl -sSL https://raw.githubusercontent.com/0x01-0xff/CloudSetup/master/CleanUpALI/aegis_uninstall/uninstall.sh | bash
echo
echo "----------------------------------------"
echo "Uninstall aegis quartz aliservice [OK] +"
echo "----------------------------------------"
echo
rm -rf /usr/local/aegis
rm -rf /usr/local/aegis*
rm -rf /usr/sbin/aliyun-service
rm -rf /lib/systemd/system/aliyun.service
rm -rf /etc/init.d/agentwatch
rm -rf /usr/sbin/aliyun-service.backup
rm -rf /usr/sbin/aliyun_installer
rm -rf /usr/local/share/aliyun-assist
echo
echo "---------------------------------------------"
echo "Uninstall aegis quartz aliservice file [OK] +"
echo "---------------------------------------------"
echo

echo
echo Please reboot !

# rpm -Uvh --force https://raw.githubusercontent.com/MeowLove/AlibabaCloud-CentOS7-Pure-and-safe/master/download/epel-release/centos-release.rpm --quiet
# rpm -Uvh --force https://raw.githubusercontent.com/MeowLove/AlibabaCloud-CentOS7-Pure-and-safe/master/download/epel-release/epel-release-latest-7.noarch.rpm --quiet
# curl -sSL https://raw.githubusercontent.com/MeowLove/AlibabaCloud-CentOS7-Pure-and-safe/master/download/kill/aegis/quartz_uninstall.sh | bash
# curl -sSL https://raw.githubusercontent.com/MeowLove/AlibabaCloud-CentOS7-Pure-and-safe/master/download/kill/aegis/uninstall.sh | bash