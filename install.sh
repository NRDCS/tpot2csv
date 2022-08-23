#!/bin/bash

local_data_dir="/data/tpot2csv"
config_dir="/opt/tpot2csv"
VHOST_CONF="tpot2csv.conf"
server_name=$(. .env && echo $SERVER_NAME)
admin_email=$(. .env && echo $ADMIN_EMAIL)
server_name_rewrite=`echo $server_name | sed 's/\./\\\\\\\./g'`

# Create folder for logs and feed data, under /data according to t-pot fileschema
if [ ! -d $local_data_dir/log ]; then
	mkdir -p $local_data_dir/log
fi
if [ ! -d $local_data_dir/data ]; then
	mkdir -p $local_data_dir/data
fi

# Create folder for service configuration
if [ ! -d $config_dir ]; then
	mkdir -p $config_dir
fi

# Setting up service
cp docker-compose.yaml .env $config_dir/
cp tpot2csv.service /etc/systemd/system/
systemctl enable tpot2csv

# if virtual host config not ready, copy from dist and adjust names
if [ ! -f $VHOST_CONF ]; then
	cp $VHOST_CONF.dist $VHOST_CONF
	sed -i "s/ServerAdmin .*/ServerAdmin $admin_email/" $VHOST_CONF
	sed -i "s/ServerName .*/ServerName $server_name/" $VHOST_CONF
	sed -i "s/RewriteCond\ %{HTTP_HOST} \!\^.* \[NC]/RewriteCond\ %{HTTP_HOST} \!\^$server_name_rewrite [NC]/" $VHOST_CONF
	sed -i "s/RewriteCond\ %{SERVER_NAME} .*/RewriteCond\ %{SERVER_NAME}\ =$server_name/" $VHOST_CONF
fi

# compile docker and bring it up
docker-compose build
