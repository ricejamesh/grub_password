# grub_password
Simple script to lock down grub2 access.

This script will replace /etc/grub.d/01_users with a user defined version which sets a username and password for accessing grub2 configuration settings at boot time.

Execution of this script as a non-root user will create a local verion of the 01_users file.  As root, it will create the file in the appropriate location and update the boot copy of grub.cfg located at /boot/grub2/grub.cfg. 

Commenting/Uncommenting line 17, DEFAULT_PASSWORD allows for default hard-coded or interactive password generation.

