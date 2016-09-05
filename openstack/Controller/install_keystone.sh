#!/bin/bash

#### Define Env
red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
yellow='\e[1;33m%s\e[0m\n'

LOCALHOSTNAME=$1
os_url=http://$LOCALHOSTNAME:35357/v3
os_token=ADMINTOKEN

printf "\n\n #### Start Keystone Installation \n"

	### Install
	printf " ### Install Packages "
		if apt-get install keystone apache2 libapache2-mod-wsgi -y >> ./logs/keystone.log 2>&1; then
					printf $green " --> done"
		else
			printf $red " --> Could not install Keystone Packages - see $(pwd)/logs/keystone.log"
		fi		
	
	printf " ### Stop and disable Keystone Service \n"
		### Stop Keystone service'
		service keystone stop >> ./logs/keystone.log 2>&1
		### Disable Keystone Service
		echo "manual" > /etc/init/keystone.override

	printf " ### Configure Keystone and Apache"
		cp ./configs/keystone.conf /etc/keystone/keystone.conf
		cp ./configs/apache2.conf /etc/apache2/apache2.conf
		cp ./configs/wsgi-keystone.conf /etc/apache2/sites-available/wsgi-keystone.conf
		sed -i '/admin_token*/c\admin_token = '$os_token /etc/keystone/keystone.conf
		sed -i '/connection = mysql+pymysql:*/c\connection = mysql+pymysql://keystone:Password123!@'$LOCALHOSTNAME'/keystone' /etc/keystone/keystone.conf
		sed -i '/ServerName*/c\ServerName '$LOCALHOSTNAME /etc/apache2/apache2.conf
		sed -i '/Listen 80/c\Listen 88' /etc/apache2/ports.conf
	printf $green " --> done\n"

### Populate Database
	printf " ### Populate Keystone Database "
		if su -s /bin/sh -c "keystone-manage db_sync" keystone >> ./logs/keystone.log 2>&1; then
			printf $green " --> done"
		else
			printf $red " --> Could not populate Keystone Database - see $(pwd)/logs/keystone.log"		
		fi

### Enable vHost
	printf " ### Enable vHost"
		ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled
	printf $green " --> done"		
	
### Restart Apache2
	printf " ### Restart Apache2 Service"
		if service apache2 restart >> ./logs/keystone.log 2>&1; then
			printf $green " --> done"
		else
			printf $red " --> Could not restart Keystone Service - see $(pwd)/logs/keystone.log"			
		fi
### Remove Dummy Database
	printf " ### Remove Keystone Dummy Database"
		rm -f /var/lib/keystone/keystone.db
	printf $green " --> done"

	printf " ### Create Keystone Services \n"
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 service create --name keystone --description "OpenStack Identity" identity >> ./logs/keystone.log 2>&1; 			then printf " ## Created Keystone Service Keystone (identity) \n"; 	else printf " ## Could not create Keystone Service Keystone (identity) - see $(pwd)/logs/keystone.log\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 service create --name glance --description "OpenStack Image" image >> ./logs/keystone.log 2>&1; 					then printf " ## Created Keystone Service Glance (image) \n"; 		else printf " ## Could not create Keystone Service Glance (image) - see $(pwd)/logs/keystone.log\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 service create --name nova --description "OpenStack Compute" compute >> ./logs/keystone.log 2>&1; 				then printf " ## Created Keystone Service Nova (compute) \n"; 		else printf " ## Could not create Keystone Service Nova (compute) - see $(pwd)/logs/keystone.log\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 service create --name neutron --description "OpenStack Networking" network >> ./logs/keystone.log 2>&1; 		then printf " ## Created Keystone Service Neutron (network) \n"; 	else printf " ## Could not create Keystone Service Neutron (network) - see $(pwd)/logs/keystone.log\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 service create --name cinder --description "OpenStack Block Storage" volume >> ./logs/keystone.log 2>&1; 		then printf " ## Created Keystone Service Cinder (volume) \n"; 		else printf " ## Could not create Keystone Service Cinder (volume) - see $(pwd)/logs/keystone.log\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 service create --name cinderv2 --description "OpenStack Block Storage" volumev2 >> ./logs/keystone.log 2>&1; then printf " ## Created Keystone Service Cinder (volumev2) \n"; 	else printf " ## Could not create Keystone Service Cinder (volumev2) - see $(pwd)/logs/keystone.log\n"; fi
	printf " ### Create Endpoints "
		#Keystone
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne identity public http://$LOCALHOSTNAME:5000/v2.0 >> ./logs/keystone.log 2>&1; 		then printf " ## Created Keystone public endpoint\n"; 	else printf "Could not create Keystone public endpoint\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne identity internal http://$LOCALHOSTNAME:5000/v2.0 >> ./logs/keystone.log 2>&1; 		then printf " ## Created Keystone internal endpoint\n"; 	else printf "Could not create Keystone internal endpoint\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne identity admin http://$LOCALHOSTNAME:35357/v2.0  >> ./logs/keystone.log 2>&1; 	then printf " ## Created Keystone admin endpoint\n"; 	else printf "Could not create Keystone admin endpoint\n"; fi
		#Glance
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne image public http://$LOCALHOSTNAME:9292 >> ./logs/keystone.log 2>&1; 		then printf " ## Created Glance public endpoint\n"; 	else printf "Could not create Glance public endpoint\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne image internal http://$LOCALHOSTNAME:9292 >> ./logs/keystone.log 2>&1; 	then printf " ## Created Glance internal endpoint\n"; 	else printf "Could not create Glance internal endpoint\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne image admin http://$LOCALHOSTNAME:9292 >> ./logs/keystone.log 2>&1; 		then printf " ## Created Glance admin endpoint\n"; 	else printf "Could not create Glance admin endpoint\n"; fi
		## Nova
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne compute public http://$LOCALHOSTNAME:8774/v2/%\(tenant_id\)s >> ./logs/keystone.log 2>&1; 		then printf " ## Created Nova public endpoint\n"; 	else printf "Could not create Nova public endpoint\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne compute internal http://$LOCALHOSTNAME:8774/v2/%\(tenant_id\)s >> ./logs/keystone.log 2>&1; 	then printf " ## Created Nova internal endpoint\n"; 	else printf "Could not create Nova internal endpoint\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne compute admin http://$LOCALHOSTNAME:8774/v2/%\(tenant_id\)s >> ./logs/keystone.log 2>&1; 		then printf " ## Created Nova admin endpoint\n"; 	else printf "Could not create Nova admin endpoint\n"; fi		
		## Neutron
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne network public http://$LOCALHOSTNAME:9696 >> ./logs/keystone.log 2>&1; 		then printf " ## Created Neutron public endpoint\n"; 	else printf "Could not create Neutron public endpoint\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne network internal http://$LOCALHOSTNAME:9696 >> ./logs/keystone.log 2>&1; 	then printf " ## Created Neutron internal endpoint\n"; 	else printf "Could not create Neutron internal endpoint\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne network admin http://$LOCALHOSTNAME:9696 >> ./logs/keystone.log 2>&1; 		then printf " ## Created Neutron admin endpoint\n"; 	else printf "Could not create Neutron admin endpoint\n"; fi
		## Cinder
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne volume public http://$LOCALHOSTNAME:8776/v1/%\(tenant_id\)s >> ./logs/keystone.log 2>&1; 			then printf " ## Created Cinder public endpoint\n"; 		else printf "Could not create Cinder public endpoint\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne volume internal http://$LOCALHOSTNAME:8776/v1/%\(tenant_id\)s >> ./logs/keystone.log 2>&1; 		then printf " ## Created Cinder internal endpoint\n";	 	else printf "Could not create Cinder internal endpoint\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne volume admin http://$LOCALHOSTNAME:8776/v1/%\(tenant_id\)s >> ./logs/keystone.log 2>&1; 		then printf " ## Created Cinder admin endpoint\n"; 		else printf "Could not create Cinder admin endpoint\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne volumev2 public http://$LOCALHOSTNAME:8776/v2/%\(tenant_id\)s >> ./logs/keystone.log 2>&1; 		then printf " ## Created Cinderv2 public endpoint\n"; 	else printf "Could not create Cinderv2 public endpoint\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne volumev2 internal http://$LOCALHOSTNAME:8776/v2/%\(tenant_id\)s >> ./logs/keystone.log 2>&1;	then printf " ## Created Cinderv2 internal endpoint\n"; else printf "Could not create Cinderv2 internal endpoint\n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 endpoint create --region RegionOne volumev2 admin http://$LOCALHOSTNAME:8776/v2/%\(tenant_id\)s >> ./logs/keystone.log 2>&1; 	then printf " ## Created Cinderv2 admin endpoint\n"; 	else printf "Could not create Cinderv2 admin endpoint\n"; fi
	printf " ### Create Projects "		
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 project create --domain default --description "Admin Project" admin >> ./logs/keystone.log 2>&1; 	then printf " ## Created Project admin\n"; 	else printf "Could not create Project admin \n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 project create --domain default --description "Service Project" service >> ./logs/keystone.log 2>&1; 	then printf " ## Created Project service\n"; 	else printf "Could not create Project service \n"; fi
	printf " ### Create Roles "
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 role create admin  >> ./logs/keystone.log 2>&1; 	then printf " ## Created Role admin\n"; 	else printf "Could not create role admin \n"; fi
	printf " ### Create Users "		
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 user create --domain default --password Password123! admin  >> ./logs/keystone.log 2>&1; 		then printf " ## Created User  admin\n"; 		else printf "Could not create User admin \n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 user create --domain default --password Password123! glance  >> ./logs/keystone.log 2>&1; 		then printf " ## Created User  glance\n"; 		else printf "Could not create User glance \n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 user create --domain default --password Password123! nova  >> ./logs/keystone.log 2>&1; 		then printf " ## Created User  nova\n"; 		else printf "Could not create User nova \n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 user create --domain default --password Password123! neutron  >> ./logs/keystone.log 2>&1; 	then printf " ## Created User  neutron\n"; 	else printf "Could not create User neutron \n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 user create --domain default --password Password123! cinder  >> ./logs/keystone.log 2>&1; 		then printf " ## Created User  cinder\n"; 		else printf "Could not create User cinder \n"; fi
	printf " ### Map User to Role and Project "
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 role add --project admin --user admin admin >> ./logs/keystone.log 2>&1; 		then printf " ## Map user admin to project admin and role admin \n"; 		else printf "Could not map user admin to project admin and role admin  \n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 role add --project service --user glance admin >> ./logs/keystone.log 2>&1; 	then printf " ## Map user glance to project service and role admin \n"; 	else printf "Could not map user glance to project service and role admin  \n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 role add --project service --user nova admin >> ./logs/keystone.log 2>&1; 		then printf " ## Map user nova to project service and role admin \n"; 		else printf "Could not map user nova to project service and role admin  \n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 role add --project service --user neutron admin >> ./logs/keystone.log 2>&1; 	then printf " ## Map user neutron to project service and role admin \n"; 	else printf "Could not map user neutron to project service and role admin  \n"; fi
		if openstack --os-url $os_url --os-token=$os_token --os-identity-api-version 3 role add --project service --user cinder admin >> ./logs/keystone.log 2>&1; 	then printf " ## Map user cinder to project service and role admin \n"; 		else printf "Could not map user cinder to project service and role admin  \n"; fi
		

	printf " ### Undo Admin-Token "
		#Undo Admin-Token
		sed -i '/admin_token*/c\#admin_token = '$os_token /etc/keystone/keystone.conf
	printf $green " --> done"	