#!/bin/bash

if [[ -z "$( command -v git )" ]];
then
    echo "Install git"

    if [[ -n "$( command -v git )" ]];
    then
        sudo apt update
        sudo apt install git
    elif [[ -n "$( command -v yum )" ]];
    then
        sudo yum update
        sudo yum install git
    else
        echo "You need install git"
        return 1
    fi
fi

if [[ ! -d $HOME/git-subrepo ]];
then
    git clone https://github.com/ingydotnet/git-subrepo $HOME/git-subrepo
    echo "source $HOME/git-subrepo/.rc" >> ~/.bashrc
fi

source $HOME/git-subrepo/.rc
git subrepo version
