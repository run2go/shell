#!/bin/sh

#default prompt
#'\[\e[2m\][\t] \[\e[0;1;38;5;209m\]\u\[\e[0;2m\]@\[\e[0;1;38;5;215m\]\H\[\e[0;2m\]:\[\e[0;38;5;105m\]\w\[\e[0m\] \[\e[38;5;215m\]❯\[\e[0m\] '

# Function definitions
init_sh() {
    install_dependencies curl

    curl -fsSL https://raw.githubusercontent.com/run2go/shell/main/sh/shrc -o ~/.shrc
    . ~/.shrc
}

init_bash() {
    install_dependencies curl bash vim bash sed jq git htop

    curl -fsSL https://raw.githubusercontent.com/run2go/shell/main/vim/vimrc -o ~/.vimrc
    curl -fsSL https://raw.githubusercontent.com/run2go/shell/main/bash/bashrc -o ~/.bashrc
    . ~/.bashrc

    # Decide on machine type
    case $2 in
        1) prompt_user='[0;1;38;5;197m\]';; #root
        2) prompt_user='[0;1;38;5;209m\]';; #user
        *) echo "Invalid machine: '$2'";;
    esac

    # Decide on user type
    case $1 in
        1) prompt_host='[0;1;38;5;113m\]';; #local
        2) prompt_host='[0;1;38;5;218m\]';; #vm
        3) prompt_host='[0;1;38;5;215m\]';; #dev
        4) prompt_host='[0;1;38;5;203m\]';; #prod
        *) echo "Invalid user: '$1'";;
    esac

    # Construct new prompt
    prompt="'\[\e[2m\][\t] \[\e$prompt_user\u\[\e[0;2m\]@\[\e$prompt_host\H\[\e[0;2m\]:\[\e[0;38;5;105m\]\w\[\e[0m\] \[\e[38;5;215m\]❯\[\e[0m\] '"
    # Update PS1 prompt in bashrc file
    sed -i "s/^\(DEFAULT_PROMPT\s*=\s*\).*\$/\1$prompt/" ~/.bashrc
}

init_zsh() {
    install_dependencies curl bash

    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_dependencies() {
    if [ -x "$(command -v apk)" ]; then
        if [ "$(id -u)" -eq 0 ]; then
            apk add --no-cache "$@"
        else
            sudo apk add --no-cache "$@"
        fi
    elif [ -x "$(command -v apt-get)" ]; then
        if [ "$(id -u)" -eq 0 ]; then
            apt-get install "$@"
        else
            sudo apt-get install "$@"
        fi
    elif [ -x "$(command -v dnf)" ]; then
        if [ "$(id -u)" -eq 0 ]; then
            dnf install "$@"
        else
            sudo dnf install "$@"
        fi
    elif [ -x "$(command -v pacman)" ]; then
        if [ "$(id -u)" -eq 0 ]; then
            pacman -S "$@"
        else
            sudo pacman -S "$@"
        fi
    elif [ -x "$(command -v zypper)" ]; then
        if [ "$(id -u)" -eq 0 ]; then
            zypper install "$@"
        else
            sudo zypper install "$@"
        fi
    else
        echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: '$@'">&2;
    fi
}

# Sample: ./init.sh 2 1 2
# Use transfer parameter if provided
desired_shell=$1
desired_machine=$2
#desired_user=$3

# Determine desired shell
while [ -z "$desired_shell" ]; do
    echo "Shell selection: sh (1), bash (2), zsh (3)"
    read -r desired_shell < /dev/tty
done

# Determine machine type
while [ -z "$desired_machine" ]; do
    echo "Server selection: local (1), vm (2), development (3), production (4)"
    read -r desired_machine < /dev/tty
done


# Determine if user is root
if [ "$(id -u)" -eq 0 ]; then
    desired_user=1
else
    desired_user=2
fi

# Overwrite default profile file
wget https://raw.githubusercontent.com/run2go/shell/main/profile -O ~/.profile

# Initialize & configure shell
case $desired_shell in
    1) init_sh $desired_machine $desired_user;;
    2) init_bash $desired_machine $desired_user;;
    2) init_zsh;;
    *) echo "Invalid shell selection: '$desired_shell'" ;;
esac
