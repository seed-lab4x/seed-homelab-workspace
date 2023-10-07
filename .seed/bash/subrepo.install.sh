#!/bin/bash

if [[ ! -d $HOME/git-subrepo ]];
then
    git clone https://github.com/ingydotnet/git-subrepo $HOME/git-subrepo
    echo "source $HOME/git-subrepo/.rc" >> ~/.bashrc
fi

source $HOME/git-subrepo/.rc
git subrepo version
