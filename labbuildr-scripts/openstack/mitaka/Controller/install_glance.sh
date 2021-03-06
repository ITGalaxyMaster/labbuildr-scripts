#!/bin/bash

#### Define Env
red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
yellow='\e[1;33m%s\e[0m\n'

LOCALHOSTNAME=$1

printf "\n\n #### Start Glance Installation \n"

### Install
	printf " ### Install Packages "
		if apt-get install glance python-glanceclient -y >> /tmp/os_logs/glance.log 2>&1; then
					printf $green " --> done"
		else
			printf $red " ERROR --> Could not install Glance Packages - see /tmp/os_logs/glance.log"
		fi				

#Copy Predefined Configs
	printf " ### Configure Glance "
		cp ./configs/glance-api.conf /etc/glance/glance-api.conf
		cp ./configs/glance-registry.conf /etc/glance/glance-registry.conf

		#Configure Glance-Api
		sed -i '/connection = mysql+pymysql:*/c\connection = mysql+pymysql://glance:Password123!@'$LOCALHOSTNAME'/glance' /etc/glance/glance-api.conf
		sed -i '/auth_uri = */c\auth_uri = http://'$LOCALHOSTNAME':5000' /etc/glance/glance-api.conf
		sed -i '/auth_url = */c\auth_url = http://'$LOCALHOSTNAME':35357' /etc/glance/glance-api.conf

		#Configure Glance-Registry
		sed -i '/connection = mysql+pymysql:*/c\connection = mysql+pymysql://glance:Password123!@'$LOCALHOSTNAME'/glance' /etc/glance/glance-registry.conf
		sed -i '/auth_uri = */c\auth_uri = http://'$LOCALHOSTNAME':5000' /etc/glance/glance-registry.conf
		sed -i '/auth_url = */c\auth_url = http://'$LOCALHOSTNAME':35357' /etc/glance/glance-registry.conf
	printf $green " --> done\n"
	
	### Populate Database
	printf " ### Populate Glance Database"
		if su -s /bin/sh -c "glance-manage db_sync" glance >> /tmp/os_logs/glance.log 2>&1 >> /tmp/os_logs/glance.log 2>&1; then
			printf $green " --> done"
		else
			printf $red " ERROR --> Could not populate Glance Database - see /tmp/os_logs/glance.log"		
		fi

	### Restart Glance-Api
	printf " ### Restart Glance Services \n"
		if service glance-api restart >> /tmp/os_logs/glance.log 2>&1; 		then printf $green " --> Restart Glance-Api done"; 			else printf $red " ERROR --> Could not restart Glance-Api Service - see /tmp/os_logs/glance.log"; fi
		if service glance-registry restart >> /tmp/os_logs/glance.log 2>&1; then printf $green " --> Restart Glance-Registry done"; 	else printf $red " ERROR --> Could not restart Glance-Registry Service - see /tmp/os_logs/glance.log"; fi		
	
	#Remove glance dummy database
	printf " ### Remove Glance Dummy Database"
		rm -f /var/lib/glance/glance.sqlite
	printf $green " --> done"
	