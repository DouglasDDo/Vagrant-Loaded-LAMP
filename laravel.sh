#!/usr/bin/env bash

#User input
PROJECT_NAME="PROJECTNAME"

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

echo "Adding stuff to Composer.json"
composer require --dev --no-update way/generators:dev-master
sed -i "/WorkbenchServiceProvider/a \\\t\t'Way\\\Generators\\\GeneratorsServiceProvider'," /vagrant/${PROJECT_NAME}/app/config/app.php
cd /vagrant/${PROJECT_NAME}
composer dump-autoload
composer update

echo "Final update"
sudo apt-get update

echo "ROCK N' ROLL!"
