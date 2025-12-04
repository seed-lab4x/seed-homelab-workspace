#!/bin/bash

set -e

if [[ -z "$( command -v crudini )" ]];
then
    echo "Install crudini"

    if [[ -n "$( command -v apt )" ]];
    then
        sudo apt update
        sudo apt install crudini
    elif [[ -n "$( command -v yum )" ]];
    then
        sudo yum update
        sudo yum install crudini
    else
        echo "You need install crudini"
        exit 1
    fi
fi

sudo crudini --set /etc/wsl.conf automount options metadata,uid=1000,gid=1000,case=off

echo "NOTE: need reboot wsl"

# sudo touch /var/run/reboot-required
# sudo killall -r '.*'
if [[ -n "$(command -v wsl.exe)" ]];
then
    echo "terminate wsl $WSL_DISTRO_NAME"
    wsl.exe --terminate $WSL_DISTRO_NAME
else
    echo "You need exit wsl and run 'wsl --shutdown' or 'wsl --terminate $WSL_DISTRO_NAME'"
fi
