#!/bin/bash

set -e

if [[ -n "$(command -v update-ca-certificates)" ]];
then
    sudo update-ca-certificates --fresh
fi

if [[ -z "$(command -v pip)" ]];
then
    if [[ -n "$(command -v apt)" ]];
    then
        sudo apt update
        sudo apt install -y python3-pip
    elif [[ -n "$(command -v yum)" ]];
    then
        sudo yum update
        sudo yum install -y python3-pip
    else
        echo "Please install pip"
        return 1
    fi
fi

sudo pip config set global.break-system-packages true
pip config set global.break-system-packages true
pip install --upgrade pip

if [[ -n "$(command -v ssh)" ]];
then
    if [[ -n "$(command -v apt)" ]];
    then
        sudo apt update
        sudo apt install -y openssh-client
    elif [[ -n "$(command -v yum)" ]];
    then
        sudo yum update
        sudo yum install -y openssh-clients
    else
        echo "Please install openssh-client"
        return 1
    fi
fi

if [[ -z "$(command -v ansible)" ]];
then
    pip install ansible
    source ~/.profile
fi

ansible --version
