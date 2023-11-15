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


# get seed json
[[ -z "$seed_json" ]] && seed_json="$( cat "$workspace_path/seed.json" | jq '.seed | values' )"
[[ -z "$seed_json" ]] && seed_json="{}"

# get seed.path
[[ -z "$seed_path" ]] && seed_path="$( echo $seed_json | jq -r '.path | values' )"
[[ -z "$seed_path" ]] && seed_path=".seed"

# get seed.url
[[ -z "$seed_url" ]] && seed_url="$( echo $seed_json | jq -r '.url | values' )"
[[ -z "$seed_url" ]] && seed_url="$workspace_url_dirname/${workspace_name//workspace/subrepo}.git"
[[ $seed_url =~ ^\.\.\/ ]] && seed_url="$( echo $seed_url | sed -e "s|\.\.\/|$workspace_url_dirname\/|g" )"

# get seed.customize
[[ -z "$seed_customize" ]] && seed_customize="$( echo $seed_json | jq -r '.customize | values' )"
[[ -z "$seed_customize" ]] && seed_customize="true"


# set seed subrepo
echo "=========="
cd $workspace_path

# set subrepo_realpath/subrepo_subdir/subrepo_file
if [[ -d "$workspace_path/$seed_path" ]];
then
    subrepo_realpath="$workspace_path/$seed_path"
    subrepo_subdir="$seed_path"
elif [[ -f "$source_directory/../.gitrepo" ]];
then
    subrepo_realpath="$( realpath $source_directory/../ )"
    subrepo_subdir="$( echo $subrepo_realpath | sed -e "s|$workspace_path/||" )"
else
    subrepo_realpath=$PWD
    read -p "Enter your '.seed' subrepo path [$subrepo_realpath]: " read_path
    subrepo_realpath=${read_path:-$subrepo_realpath}
    subrepo_subdir="$( basename $subrepo_realpath )"
fi
subrepo_file="$subrepo_realpath/.gitrepo"

# install git subrepo
subrepo_cmd="$( git subrepo version 2>/dev/null | grep 'git-subrepo Version' | awk '{print $3}'  )"
if [[ -z "$subrepo_cmd" && -f "$source_directory/subrepo.install.sh" ]];
then
    source $source_directory/subrepo.install.sh
elif [[ -z "$subrepo_cmd" && -f "$subrepo_realpath/subrepo.install.sh" ]];
then
    source $subrepo_realpath/subrepo.install.sh
fi

# set subrepo.remote
[[ -f $subrepo_file ]] && subrepo_remote="$( git config --file=$subrepo_file --get subrepo.remote )"
[[ -z "$subrepo_remote" ]] && subrepo_remote="$seed_url"

# set subrepo.branch
[[ -f $subrepo_file ]] && subrepo_branch="$( git config --file=$subrepo_file --get subrepo.branch )"
[[ -z "$subrepo_branch" ]] && subrepo_branch="main"


# init
if [[ ! -f $subrepo_file ]];
then
    echo "Need to init subrepo '$subrepo_subdir' -> $subrepo_remote $subrepo_branch"
    git subrepo init \
        --remote=$subrepo_remote \
        --branch=$subrepo_branch \
        $subrepo_subdir
fi

# push
echo "Pushing..."
if [[ "$seed_customize" == "true" ]];
then
    # customize
    # get repo url
    repo_url="$( git config --get remote.origin.url )"
    repo_url_dirname="$( dirname $repo_url )"

    customize_subrepo_name="$( basename $subrepo_remote )"
    customize_subrepo_remote="$repo_url_dirname/$customize_subrepo_name"

    if [[ ! "$subrepo_remote" == "$customize_subrepo_remote" ]]
    then
        echo "!!!!!!!!!!"
        echo "The actual push remote is different from the .gitrepo fix later."
        echo "push to '$customize_subrepo_remote' but messaged '$subrepo_remote'"
        echo "!!!!!!!!!!"

        git subrepo push \
            --message="git subrepo push --remote=$subrepo_remote --branch=$subrepo_branch $subrepo_subdir" \
            --remote=$customize_subrepo_remote \
            --branch=$subrepo_branch \
            $subrepo_subdir

        echo "Fix .gitrepo remote to correct by rebase subrepo commit."
        # rebase last commit
        git subrepo config --force $subrepo_subdir remote $subrepo_remote
        git add $subrepo_subdir/.gitrepo
        git commit --amend --no-edit
        return
    fi
fi

git subrepo push \
    --remote=$subrepo_remote \
    --branch=$subrepo_branch \
    $subrepo_subdir
