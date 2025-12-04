#!/bin/bash

set -e

if [[ -n "$(command -v update-ca-certificates)" ]];
then
    sudo update-ca-certificates --fresh
fi

declare -A pkg_map=(
    ["pipx"]="pipx"
    ["ssh"]="openssh-client"
)

declare -a pkgs_to_install=()
for cmd in "${!pkg_map[@]}"; do
    if [[ -z "$(command -v $cmd)" ]]; then
        pkgs_to_install+=("${pkg_map[$cmd]}")
    fi
done

if [[ ${#pkgs_to_install[@]} -gt 0 ]];
then
    if [[ -n "$(command -v apt)" ]];
    then
        sudo apt update
        sudo apt install -y "${pkgs_to_install[@]}"
    elif [[ -n "$(command -v yum)" ]];
    then
        pkgs_for_yum=("${pkgs_to_install[@]/openssh-client/openssh-clients}")
        sudo yum update
        sudo yum install -y "${pkgs_for_yum[@]}"
    else
        echo "Please install: ${pkgs_to_install[*]}"
        exit 1
    fi
fi


pipx install ansible-core==2.15.5
pipx inject --pip-args='--no-deps' ansible-core ansible==8.5.0
pipx runpip ansible-core config set global.break-system-packages true

. ~/.profile

ansible --version
