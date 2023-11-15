#!/bin/bash

set -e

if [[ -z "$( command -v crudini )" ]];
then
    echo "Install crudini"

    if [[ -n "$( command -v apt )" ]];
    then
        sudo apt install crudini
    elif [[ -n "$( command -v yum )" ]];
    then
        sudo yum install crudini
    else
        echo "You need install crudini"
        return 1
    fi
fi

sudo crudini --set /etc/wsl.conf interop appendWindowsPath false

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
