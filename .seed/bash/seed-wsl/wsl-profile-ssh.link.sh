#!/bin/bash

set -e

if [[ -z "$( command -v wslvar )" ]];
then
    echo "Install wslu"
    if [[ -z "$( command -v curl )" ]];
    then
        echo "Install curl"
        if [[ -n "$( command -v apt )" ]];
        then
            sudo apt update
            sudo apt install curl
        elif [[ -n "$( command -v yum )" ]];
        then
            sudo yum update
            sudo yum install curl
        else
            echo "You need install curl"
            exit 1
        fi
    fi
    curl -sL https://raw.githubusercontent.com/wslutilities/wslu/master/extras/scripts/wslu-install | bash
fi

win_userprofile="$( wslvar USERPROFILE )"
win_username="$( wslvar USERNAME )"
win_profile="${win_userprofile/$win_username/}"

wsl_username="$( whoami )"
wsl_profile="/mnt/metadata/profile"
wsl_ssh_path="/mnt/metadata/profile/$win_username/.ssh"

usr_ssh_path="$HOME/.ssh"

mount_with_metadata="$( mount | grep "$wsl_profile" | cat | grep 'metadata' | cat )"
if [[ -z "$mount_with_metadata" ]];
then
    echo "Mount windows '$win_profile' with metadata option."
    [[ -d "$wsl_profile" ]] & sudo mkdir -p "$wsl_profile"
    sudo mount -t drvfs -o 'metadata' "$win_profile" "$wsl_profile"
fi

# fix persistence loss, use fstab
fstab_entry="$win_profile $wsl_profile drvfs metadata 0 0"
if ! grep -qF "$fstab_entry" /etc/fstab; then
    echo "$fstab_entry" | sudo tee -a /etc/fstab
    sudo mount -a
fi

if [[ -L "$usr_ssh_path" ]];
then
    real_ssh_path="$( cd -P "$usr_ssh_path" && pwd )"

    if [[ "$real_ssh_path" == "$wsl_ssh_path" ]];
    then
        wsl_ssh_path=''
    else
        echo "Remove symbolic link '$usr_ssh_path' pointing to '$real_ssh_path'"
        rm "$usr_ssh_path"
    fi
elif [[ -e "$usr_ssh_path" ]]; then
    backup_ssh_path="$usr_ssh_path.bak.$( date +%s )"
    echo "Backup '$usr_ssh_path' to '$backup_ssh_path'"
    mv "$usr_ssh_path" "$backup_ssh_path"
fi

if [[ -n "$wsl_ssh_path" ]];
then
    echo "Link '$wsl_ssh_path' to '$usr_ssh_path'"
    sudo ln -s "$wsl_ssh_path" "$usr_ssh_path"

    echo "Fix owner '$wsl_username:$wsl_username' mode '700'"
    sudo chown -R $wsl_username:$wsl_username "$usr_ssh_path"
    sudo chmod -R 700 "$usr_ssh_path/"
fi

echo "List ssh path '$usr_ssh_path/'"
ls -la "$usr_ssh_path/"
