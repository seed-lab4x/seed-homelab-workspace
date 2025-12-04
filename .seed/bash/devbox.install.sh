#!/bin/bash

set -e

# 
[[ -z "$source_directory" ]] && source_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ "$source_directory" == "/dev/fd" ]] && source_directory="$PWD"

# install dependencies
if [[ -n "$(command -v apt)" ]];
then
    sudo apt update
    sudo apt install -y curl xz-utils
elif [[ -n "$(command -v yum)" ]];
then
    # ignore error like 100 exit code
    sudo yum check-update || true
    sudo yum install -y curl xz
else
    echo "Please install curl xz"
    exit 1
fi

# install nix
if [[ -z "$(command -v nix)" ]];
then
    # sh <(curl -L https://nixos.org/nix/install) --no-daemon
    curl -fsSL https://nixos.org/nix/install | bash -s -- --no-daemon
fi

# check nix version
nix --version

# install devbox
if [[ -z "$(command -v devbox)" ]];
then
    curl -fsSL https://get.jetpack.io/devbox | bash -s -- --force
fi

# check devbox version
devbox version

# find workspace
workspace_path="$source_directory"
while [[ ! -f "$workspace_path/seed.json" ]];
do
    workspace_path=$(realpath "$workspace_path/../")
    if [[ "$workspace_path" == "/" ]]
    then
        echo "Unable to find workspace seed.json file in parent directory."
        exit 1
    fi
done

# install workspace packages 
devbox install --config $workspace_path
