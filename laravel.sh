#!/usr/bin/env bash

#User input
PROJECT_NAME="PROJECTNAME"
HOST_NAME="'HOSTNAME'"
DB_PASSWORD="'DBPASSWORD'"
DB_NAME="'DBNAME'"

#Laravel Configuration Script
echo "Installing Laravel."
cd /vagrant
composer create-project laravel/laravel ${PROJECT_NAME} --prefer-dist

echo "Updating Laravel Composer file to have Laravel work out of the box"
cd /vagrant/${PROJECT_NAME}
composer update
composer self-update

echo "Setting document root"
sudo rm -rf /var/www
sudo ln -fs /vagrant/${PROJECT_NAME}/public /var/www

cat << EOF | sudo tee -a /etc/apache2/apache2.conf
<VirtualHost *:80>
     DocumentRoot /vagrant/${PROJECT_NAME}/public
     ServerName $HOST_NAME
     <Directory "/vagrant/${PROJECT_NAME}/public">
          AllowOverride All
     </Directory>
</VirtualHost>
EOF

echo "Adding stuff to Composer.json"
composer require --dev --no-update way/generators:dev-master
sed -i "/WorkbenchServiceProvider/a \\\t\t'Way\\\Generators\\\GeneratorsServiceProvider'," /vagrant/${PROJECT_NAME}/app/config/app.php
sed -i $"{/\"classmap\"/,/]/ { s/]/],/g}}" composer.json
sed -ie "/\"classmap\"/,/],/!b;/],/a\\\t\t\"psr-4\": {},\n\\t\t\"files\": []" composer.json
composer dump-autoload
composer update

#Create development environment settings
mkdir /vagrant/${PROJECT_NAME}/app/config/development
cd /vagrant/${PROJECT_NAME}/app/config/development

#Create development env app file with debugging on
touch app.php
cat << EOF | sudo tee -a app.php
<?php

return [
    'debug' => true
];
EOF

#Create development env DB file with dev credentials
touch database.php
cat << EOF | sudo tee -a database.php
<?php
	return [
		'connections'	=>	[
			'mysql'	=>	[
				'host'      => $HOST_NAME,
				'database'  => $DB_NAME,
				'username'  => 'root',
				'password'  => $DB_PASSWORD
			]
		]
	];
EOF

cd /vagrant/${PROJECT_NAME}/bootstrap
sed -i "s/detectEnvironment(array(/detectEnvironment(function(){/g" start.php
sed -i "s/'local' => array('your-machine-name'),/return getenv('ENV') ?	: 'development';/g" start.php
sed -i "s/));/});/g" start.php

#Create custom directories.
mkdir -p /vagrant/${PROJECT_NAME}/app/abstractions/{interfaces,repositories,services}

mkdir -p /vagrant/${PROJECT_NAME}/app/views/_partials/forms

mkdir -p /vagrant/${PROJECT_NAME}/public/assets/{css,js,img}


echo "Final update"
sudo apt-get update

echo "ROCK N' ROLL!"
