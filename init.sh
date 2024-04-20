#!/bin/sh

# Function definitions
init_sh() {
    install_dependencies curl

    curl -fsSL https://raw.githubusercontent.com/run2go/shell/main/sh/shrc -o ~/.profile

    curl -fsSL https://raw.githubusercontent.com/run2go/shell/main/sh/shrc -o ~/.shrc
    . ~/.shrc
}

init_bash() {
    install_dependencies curl bash vim bash jq git htop

    curl -fsSL https://raw.githubusercontent.com/run2go/shell/main/sh/shrc -o ~/.profile

    curl -fsSL https://raw.githubusercontent.com/run2go/shell/main/bash/bashrc -o ~/.bashrc
    curl -fsSL https://raw.githubusercontent.com/run2go/shell/main/zsh/vimrc -o ~/.vimrc
    . ~/.bashrc
}

init_zsh() {
    install_dependencies curl bash vim zsh jq git htop coreutils g++ make build-essential
    
    curl -fsSL https://raw.githubusercontent.com/run2go/shell/main/sh/shrc -o ~/.profile

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    #(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /root/.bashrc
    #eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    #brew install gcc

    curl -fsSL https://raw.githubusercontent.com/run2go/shell/main/zsh/zshrc -o ~/.zshrc
    curl -fsSL https://raw.githubusercontent.com/run2go/shell/main/zsh/zshenv -o ~/.zshenv
    curl -fsSL https://raw.githubusercontent.com/run2go/shell/main/zsh/vimrc -o ~/.vimrc

    brew install zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    brew install yazi ffmpegthumbnailer unar jq poppler fd ripgrep fzf zoxide
    brew tap homebrew/cask-fonts
    brew install zsh-autocomplete
    brew install powerlevel10k

    git clone https://github.com/sachinsenal0x64/crystal-theme
    mkdir ~/.config/yazi
    cd crystal-theme
    mv theme.toml ~/.config/yazi/
    cd -
 
    echo "Recommended Font: https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#meslo-nerd-font-patched-for-powerlevel10k"
    
    chsh -s $(which zsh)
    eval zsh
}

install_dependencies() {
    if [ -x "$(command -v apk)" ]; then
        sudo apk add --no-cache "$@"
    elif [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install "$@"
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install "$@"
    elif [ -x "$(command -v pacman)" ]; then
        sudo pacman install "$@"
    elif [ -x "$(command -v zypper)" ]; then
        sudo zypper install "$@"
    else
        echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: '$@'">&2;
    fi
}

if [ ! -z "$1" ]; then
    number=$1
else
    # Prompt the user to enter a number
    echo "Enter a number (1, 2, or 3):"
    read number  # Wait for 5 seconds for user input before auto proceeding
    if [ -z "$number" ]; then
        number=1  # Default to option 1
    fi
fi

case $number in
    1) init_sh ;;
    2) init_bash ;;
    3) init_zsh ;;
    *) echo "Invalid input. Please enter 1, 2, or 3." ;;
esac

# Overwrite default profile file
wget https://raw.githubusercontent.com/run2go/shell/main/profile -O ~/.profile