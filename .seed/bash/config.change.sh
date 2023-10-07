#!/bin/bash

set -e

[[ -z "$source_directory" ]] && source_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[[ "$source_directory" == "/dev/fd" ]] && source_directory="$PWD"


if [[ -z "$( command -v jq )" ]];
then
    echo "Install jq"

    if [[ -n "$( command -v apt )" ]];
    then
        sudo apt install jq
    elif [[ -n "$( command -v yum )" ]];
    then
        sudo yum install jq
    else
        echo "You need install jq"
        return 1
    fi
fi

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

# get workspace.name
[[ -z "$workspace_name" ]] && workspace_name="$( cat "$workspace_path/seed.json" | jq -r '.workspace.name | values' )"
[[ -z "$workspace_name" ]] && workspace_name="$( basename $workspace_path )"

# get workspace.url
[[ -z "$workspace_url" ]] && workspace_url="$( cat "$workspace_path/seed.json" | jq -r '.workspace.url | values' )"
[[ -z "$workspace_url" ]] && workspace_url="$( git config --get remote.origin.url )"

# set workspace.url.dirname
workspace_url_dirname="$( dirname $workspace_url )"


# get config json
[[ -z "$config_json" ]] && config_json="$( cat "$workspace_path/seed.json" | jq '.config | values' )"
[[ -z "$config_json" ]] && config_json="{}"

# get config.name
[[ -z "$config_name" ]] && config_name="$( echo $config_json | jq -r '.name | values' )"
[[ -z "$config_name" ]] && config_name=".config"

# get config.url
[[ -z "$config_url" ]] && config_url="$( echo $config_json | jq -r '.url | values' )"
[[ -z "$config_url" ]] && config_url="$workspace_url_dirname/${workspace_name//workspace/config}.git"
[[ $config_url =~ ^\.\.\/ ]] && config_url="$( echo $config_url | sed -e "s|\.\.\/|$workspace_url_dirname\/|g" )"

# get config.customize.prompt
[[ -z "$config_customize_prompt" ]] && config_customize_prompt=$(echo $config_json | jq -r '.customize.prompt | values')
[[ -z "$config_customize_prompt" ]] && config_customize_prompt="true"

# get config.customize.confirm
[[ -z "$config_customize_confirm" ]] && config_customize_confirm=$(echo $config_json | jq -r '.customize.confirm | values')
[[ -z "$config_customize_confirm" ]] && config_customize_confirm="true"


# set config submodule
echo "=========="
cd $workspace_path

# set submodule_url by add/init config.repository
submodule_url="$( git config --get submodule.$config_name.url || echo '' )"
if [[ -z "$submodule_url" ]];
then
    # get config.branch
    [[ -z "$config_branch" ]] && config_branch=$(echo $config_json | jq -r '.branch | values')
    [[ -z "$config_branch" ]] && config_branch="main"
    # get config.path
    [[ -z "$config_path" ]] && config_path=$(echo $config_json | jq -r '.path | values')
    [[ -z "$config_path" ]] && config_path="$config_name"
    # set config.repository
    [[ -z "$config_repository" ]] && config_repository="$( echo $config_json | jq -r '.url | values' )"
    [[ -z "$config_repository" ]] && config_repository="../${workspace_name//workspace/config}.git"

    echo "Need to init submodule '$config_path' <- $config_repository $config_branch"
    git submodule add -b $config_branch $config_repository $config_path
    git submodule init $config_path
    echo "config init done."

    submodule_url="$( git config --get submodule.$config_name.url || echo '' )"
fi

# set submodule.change.to/submodule.change.url
repo_url="$( git config --get remote.origin.url )"
if [[ "$workspace_url" == "$repo_url" && "$submodule_url" == "$config_url" ]];
then
    # default workspace default config to customize config
    submodule_change_to="customize"

    # change url use username group
    repo_url_dirname="$( dirname $repo_url )"
    repo_url_rootname="$( dirname $repo_url_dirname )"
    workspace_user_name="$( git config --get user.name )"
    config_url_basename="$( basename $config_url )"
    if [[ "$repo_url_rootname" == "." ]];
    then
        re="^((https|http|git)(:\/\/|@)([^\/:]+)([\/:]))(.*)"
        if [[ $repo_url =~ $re ]];
        then
            repo_domain=${BASH_REMATCH[1]}
            submodule_change_url="$repo_domain$workspace_user_name/$config_url_basename"
        else
            echo "Unable to parse '$repo_url' by /$re/."
            return 1
        fi
    else
        submodule_change_url="$repo_url_rootname/$workspace_user_name/$config_url_basename"
    fi

    if [[ "$config_customize_prompt" == "true" ]];
    then
        read -p "Enter your '.config' submodule url [$submodule_change_url]: " read_url
        submodule_change_url=${read_url:-$submodule_change_url}
    fi
elif [[ ! "$workspace_url" == "$repo_url" && "$submodule_url" == "$config_url" ]];
then
    # customize workspace default config to customize config
    submodule_change_to="customize"

    # change url use customize workspace group
    submodule_change_url="../${workspace_name//workspace/config}.git"

    if [[ "$config_customize_prompt" == "true" ]];
    then
        echo -e "The current workspace already customized to $workspace_url."
        read -p "Enter your '.config' submodule url [$submodule_change_url]: " read_url
        submodule_change_url=${read_url:-$submodule_change_url}
    fi
elif [[ "$workspace_url" == "$repo_url" && ! "$submodule_url" == "$config_url" ]];
then
    # default workspace customize config to default config
    submodule_change_to="default"

    submodule_change_url="$config_url"
elif [[ ! "$workspace_url" == "$repo_url" && ! "$submodule_url" == "$config_url" ]];
then
    # customize workspace customize config to default config
    submodule_change_to="default"

    echo -e "The current workspace already customized to $workspace_url,\nconfig url will use absolute path."
    submodule_change_url="$config_url"
fi
echo "Change $config_name to $submodule_change_to: $submodule_change_url"


# confirm
echo "!!!!!!!!!!"
while [[ "$config_customize_confirm" == "true" ]];
do
    read -p "[DANGER]Change submodule url git unpushed commits will be lost, are you sure? (yes/no)" yn
    case $yn in
        Yes|yes|y|Y)
            break;;
        No|no|N|n)
            return;;
        *)
            echo "Please answer yes or no.";;
    esac
done

# change
git submodule deinit -f $config_name
rm -rf .git/modules/$config_name/
git config submodule.$config_name.url ${submodule_change_url}
git submodule update --recursive --remote
