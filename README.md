Vagrant-LAMP
============
These scripts and the accompanying Vagrantfile can be used to set up either a plain vanilla LAMP stack or one with a Laravel project.

It's still a work in progress but it works for the most part. 

#Instructions
Clone this repo in whichever folder you want to hold your Vagrantfile and project docroot or Laravel folder.

Open up your preferred command line interface (CLI) in the folder you just cloned to.

Run "./setup.sh" and respond to the prompts. 

That's it.

###Future Plans:
* Add environment configuration in bootstrap>start.php to Laravel.sh [Completed]
* Add option to turn on debug on install (as of 4.1.26, debug is set to false by default) [Completed]
* Add JavaScript Utility tool for Laravel
* Add basic view templates and components (partials, layouts, etc.)
* Consider: Merging this repo and the Vanilla repo
