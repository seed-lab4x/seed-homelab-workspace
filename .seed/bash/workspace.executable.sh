#!/bin/bash

source_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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

chmod -R +x $workspace_path
