# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

CURRENT_SHELL=$(getent passwd "$(whoami)" | cut -d: -f7)
#if [ -n "$BASH_VERSION" ]; then
if [ "$CURRENT_SHELL" = '/bin/zsh' ]; then
    if [ -f "$HOME/.zshrc" ]; then
        . "$HOME/.zshrc"
    fi
elif [ "$CURRENT_SHELL" = '/bin/bash' ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
else
    if [ -f "$HOME/.shrc" ]; then
        . "$HOME/.shrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# import aliases file if it exists
#if [ -f ~/.aliases ]; then
#    . ~/.aliases
#fi

