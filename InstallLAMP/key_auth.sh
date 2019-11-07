#!/bin/bash
#
# Add User And Set Login By Key
# By Huson 2018-08-01
#
clear

new_user="XXXX"
new_user_pw="xxxxxxxx"
user_group="root"
rsa_key_name="XXXX"


# Make Sure Run As root
if [[ $EUID -ne 0 ]]; then
	echo "Error: Must Be Run As root!" 1>&2
	exit 1
fi
cur_dir=`pwd`

echo
echo "adding user: $new_user"
echo
if [ $user_group != root ]; then
	groupadd $user_group
fi
useradd -g $user_group $new_user
echo $new_user_pw |passwd --stdin $new_user
#echo $new_user_pw |passwd --stdin root

echo
echo "setting rsa key: $rsa_key_name"
echo
if [ ! -f "$cur_dir/$rsa_key_name" ]; then
	echo "creating rsa key: $rsa_key_name"
	ssh-keygen -t rsa -C $new_user -f $rsa_key_name -N ""
fi
authorized_file="/home/$new_user/.ssh/authorized_keys"
if [ ! -d "/home/$new_user/.ssh" ]; then mkdir /home/$new_user/.ssh; fi
if [ ! -f "$authorized_file" ]; then touch $authorized_file; fi
cat $cur_dir/$rsa_key_name.pub >> $authorized_file
#cp -f $cur_dir/$rsa_key_name.pub /home/$new_user/.ssh/$rsa_key_name.pub
chown -R $new_user:$user_group /home/$new_user
chmod 700 -R /home/$new_user/.ssh
chmod 600 $authorized_file
#chmod 600 /home/$new_user/.ssh/$rsa_key_name.pub


# /etc/ssh/sshd_config
# PubkeyAuthentication yes
# #RSAAuthentication yes
# UsePAM yes
# ChallengeResponseAuthentication no
# PermitRootLogin no
# PasswordAuthentication no
# #AuthenticationMethods publickey,password


# Service Start
systemctl restart sshd

echo
echo "DONE."
echo "$new_user:$new_user_pw"
echo "Must be get the \"$rsa_key_name\" file to local computer."
echo
