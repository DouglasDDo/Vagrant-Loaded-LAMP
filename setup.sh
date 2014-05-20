#!/usr/bin/env bash

echo '-- Enter a unique name for your Virtual Box VM. --'
read BOXNAME

#Needs valid character check. See VirtualBox naming restrictions, if any.
#Could also just leave blank and let VirtualBox create default name.
while [[ -z $BOXNAME ]]
	do
		echo '-- You must enter a name. Try again. --'
		read BOXNAME
done
#Set the box name in Vagrantfile
sed -i "s/BOXNAME/$BOXNAME/g" Vagrantfile

echo '-- Enter an IP Address for vhost setup --'
echo '-- If no IP Address is entered, your hosting location for this project will default to localhost:8080. --'
read HOSTING

if [[ $HOSTING ]]; then
	#Check for numbers 1-3 digits in length. Check to see that each octet is less than or equal to 255.
	while [[ ! $(echo $HOSTING | egrep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}') || ! $(echo $HOSTING | awk -F'.' '$1 <=255 && $2 <= 255 && $3 <= 255 && $4 <= 255') ]]
		do
			echo '-- The IP address was not valid. Try again. --'
			read HOSTING

			#Set IP address in Vagrantfile
			sed -i "s/IPADDRESS/$HOSTING/g" Vagrantfile

			echo "-- Your project will be hosted on IP address $HOSTING. --"
			echo "-- Do not forget to set up a virtual host at this address in your hosts file on your hosting OS. --"
	done
else
	#Delete configurations used for virtual hosting and replace virtual hosting with localhost
	sed -i "s/config.vm.network \"private_network\", ip: \"IPADDRESS\"/config.vm.network :forwarded_port, host: 8080, guest: 80/g" Vagrantfile
	sed  -i '/config.vm.usable_port_range = (2200..2250)/d' Vagrantfile

	echo '-- Your project will be hosted on localhost port 8080. --'
fi

sed -i "s/IPADDRESS/$HOSTING/g" Vagrantfile lamp.sh

echo '-- If you intend on using a specific host name enter it below. --'
echo "-- If you do not enter a name, the host name will default to 'localhost' --"
read HOSTNAME

if [[ $HOSTNAME ]]; then
	sed -i "s/HOSTNAME/$HOSTNAME/g" lamp.sh laravel.sh
else
	sed -i "s/HOSTNAME/localhost/g" lamp.sh laravel.sh
fi

echo '-- Enter the base memory size of your Virtual Box VM in MB (min of 64MB, max of 8192MB ). --'
echo '-- If no number is entered, the base memory of your Virtual Box VM  will default to 1024MB. --'
read MEMORYSIZE
#Check that a number up to 4 digits in length is entered. Check to see that the number entered is between 64 and 8192.
if [[ $MEMORYSIZE ]]; then
	while [[ ! $(echo $MEMORYSIZE | egrep -E '[0-9]{1,4}') || ! $(echo $MEMORYSIZE | awk '$1 <= 8192 && $1 >=64') ]]
		do
			echo '-- Please enter a valid number --'
			read MEMORYSIZE
		done
else
	MEMORYSIZE="1024"
fi

#Set memory size in Vagrantfile
sed -i "s/MEMORYSIZE/$MEMORYSIZE/g" Vagrantfile

while true;
	do
		echo '-- Will this project be using Laravel? (y/n) --'
	    read LARAVEL
	    case $LARAVEL in
	        [Yy]* ) echo '-- You answered YES. Laravel will be installed for this project. --';
					break;;
	        [Nn]* ) echo '-- You answered NO. Laravel will not be installed for this project. --';
					LARAVEL="no";
					sed -i "/config.vm.provision :shell, :path => \"laravel.sh\"/d" Vagrantfile;
					rm laravel.sh;
					break;;
	        * ) echo '-- Please answer yes or no. --';;
	    esac
done

#Set Laravel check to "yes" or "no", depending on input
sed -i "s/LARACHECK/$LARAVEL/g" lamp.sh

#check if laravel, then prompt for environment setttings
if [[ ! $LARAVEL == "no" ]]; then
	echo "-- Enter a name for your Laravel project or leave this blank and default to 'laravel'. --";
	#Needs character validation
	read PROJECTNAME;
	if [[ $PROJECTNAME ]]; then
		sed -i "s/PROJECTNAME/$PROJECTNAME/g" laravel.sh
	else
		sed -i "s/PROJECTNAME/laravel/g" laravel.sh
	fi
fi


echo '-- Enter a name for your MySQL Database. Database names are case sensitive. --'
echo '-- If no name is entered, a default database named dbname will be created instead. --'
read DBNAME

if [[ $DBNAME ]]; then
	while [[ ! $(echo $DBNAME | egrep -E '[a-zA-Z0-9\\\_\\\$]{1,64}$') ]]; do
		echo '-- Databases have a max length of 64 characters and may only use alphanumeric characters, underscores, and dollar signs. --'
		echo '-- Please enter a valid database name. --'
		read DBNAME
	done
else
	DBNAME="dbname"
fi
#set Database name
sed -i "s/DBNAME/$DBNAME/g" lamp.sh laravel.sh

echo '-- Enter a password to be used with both MySQL and PHPMyAdmin --'
echo "-- If no password is entered, the password will default to 'root'. --"
read -s DBPASSWORD

if [[ $DBPASSWORD ]]; then
	echo
	#need while loop that checks for $,@ and space for first character of pw
else
	DBPASSWORD="root"
fi
#set Database password
sed -i "s/DBPASSWORD/$DBPASSWORD/g" lamp.sh laravel.sh

echo "-- Now running 'vagrant up' --"
vagrant up
