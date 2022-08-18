#!/bin/bash

local_data_dir="/data/tpot2csv"
$VHOST_CONF="tpot2csv.conf"


if [ ! -d $local_data_dir/logs ]; then
	mkdir -p $local_data_dir/logs
fi


if [ ! -f $VHOST_CONF ]; then
	cp $VHOST_CONF.dist $VHOST_CONF
fi

server_name=$(. .env && echo $SERVER_NAME)

admin_email=$(. .env && echo $ADMIN_EMAIL)

sed -i "s/ServerAdmin .*/ServerAdmin $admin_email/" $VHOST_CONF
server_name=`cat .env | grep ^SERVER_NAME | awk -F '=' '{print $2}'`
sed -i "s/ServerName .*/ServerName $server_name/" $VHOST_CONF
server_name_rewrite=`echo $server_name | sed 's/\./\\\\\\\./g'`
sed -i "s/RewriteCond\ %{HTTP_HOST} \!\^.*/RewriteCond\ %{HTTP_HOST} \!\^$server_name_rewrite/" $VHOST_CONF
sed -i "s/RewriteCond\ %{SERVER_NAME} .*/RewriteCond\ %{SERVER_NAME}\ =$server_name/" $VHOST_CONF


docker-compose up -d
