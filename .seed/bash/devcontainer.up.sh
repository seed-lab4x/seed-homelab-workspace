#!/bin/bash

set -e

# 
[[ -z "$source_directory" ]] && source_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ "$source_directory" == "/dev/fd" ]] && source_directory="$PWD"

# find workspace
workspace_path="$source_directory"
while [[ ! -f "$workspace_path/seed.json" ]];
do
    workspace_path=$(realpath "$workspace_path/../")
    if [[ "$workspace_path" == "/" ]]
    then
        echo "Unable to find workspace seed.json file in parent directory."
        return 1
    fi
done

# ssh path
mkdir -p $HOME/.ssh
chmod 777 $HOME/.ssh

# up devcontainer
devcontainer up \
    --workspace-folder $workspace_path \
    --mount type=bind,source=$HOME/.ssh,target=/home/vscode/.ssh \
    --remove-existing-container
