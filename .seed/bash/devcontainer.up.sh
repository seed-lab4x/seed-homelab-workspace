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

# make ssh dir
mkdir -p "$HOME/.ssh"

# check user id
user_id="$(id -u)"

# mount ssh path
if [[ "$user_id" == "0" ]];
then
    # export REMOTE_USER=root
    # up devcontainer
    # override config remote user to root
    # mount root user ssh path
    devcontainer up \
        --workspace-folder $workspace_path \
        --remove-existing-container \
        --config $workspace_path/.devcontainer/@root/devcontainer.json \
        --mount type=bind,source=/root/.ssh,target=/root/.ssh \
        "$@"
else
    # up devcontainer
    # mount current user ssh path
    # update container user(vscode)'s UID/GID to match your current user
    devcontainer up \
        --workspace-folder $workspace_path \
        --remove-existing-container \
        --config $workspace_path/.devcontainer/devcontainer.json \
        --mount type=bind,source=$HOME/.ssh,target=/home/vscode/.ssh \
        --update-remote-user-uid-default on \
        "$@"
fi
