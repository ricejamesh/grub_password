#!/bin/sh

# grub_secure
#
# This file will allow the grub2 interface be secured with a 
# username and password.  The purpose of this security measure
# is to restrict the modification of the linux boot commands
# by unauthorized users.

# Author: James Rice <James.H.Rice.1@gmail.com>
# Date: April 13, 2018.

USERS_FILE="/etc/grub.d/01_users"
GRUB_CFG="/boot/grub2/grub.cfg"

DEFAULT_USER="grubby"
DEFAULT_PASSWORD="grubby_password"

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root.  Creating test file locally..."
  USERS_FILE="./01_users.txt"
fi

read -p "Enter user name (other than root) for grub2 access [grubby]: " user

user=${user:-${DEFAULT_USER}}

if [ ${user} = "root" ]; then
  echo "Error: Cannot use root as a user name."
  exit 1
fi

if [[ ! -z ${DEFAULT_PASSWORD} ]]; then
	echo "Using DEFAULT PASSWORD..."
	# Strip out hashed password.  Using AWK
	PW_ONLY=$(echo -e "${DEFAULT_PASSWORD}\n${DEFAULT_PASSWORD}"|grub2-mkpasswd-pbkdf2|awk '/grub.pbkdf/{print$NF}')
else
	# Easy way to redirect text output to local variable and console.
	exec 5>&1
	GRUBPW_OUT=$(grub2-mkpasswd-pbkdf2| tee /dev/fd/5)

	if [[ ${GRUBPW_OUT} != *"grub.pbkdf2."* ]]; then
		  # If we do not have a successful password, just exit.
		  exit 1
	else
		  # Strip out hashed password.  Using SED
		  PW_ONLY=$(echo ${GRUBPW_OUT} | sed 's/.*\(grub.pbkdf2.*\)/\1/')
	fi
fi



echo "--- Creating new 01_users file @ ${USERS_FILE} ---"
echo "cat << EOF" > ${USERS_FILE}
echo "set superusers=\"${user}\"" >> ${USERS_FILE}
echo "password_pbkdf2 ${user} ${PW_ONLY}">> ${USERS_FILE}
echo "EOF" >> ${USERS_FILE}


# Update main grub.cfg file.  Don't bother if you are not root...
if [[ $EUID -eq 0 ]]; then
	grub2-mkconfig -o "${GRUB_CFG}"
fi

