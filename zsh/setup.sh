#!/bin/bash

install_dependencies() {
    if [ -x "$(command -v apk)" ]; then
        apk add --no-cache "$@"
    elif [ -x "$(command -v apt-get)" ]; then
        apt-get install "$@"
    elif [ -x "$(command -v dnf)" ]; then
        dnf install "$@"
    elif [ -x "$(command -v pacman)" ]; then
        pacman -s "$@"
    elif [ -x "$(command -v zypper)" ]; then
        zypper install "$@"
    else
        echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: '$@'">&2;
    fi
}

install_dependencies curl bash vim zsh jq git htop coreutils g++ make build-essential

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /root/.bashrc
#eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
#brew install gcc

curl -fsSL https://raw.githubusercontent.com/run2go/shell/main/zsh/zshrc -o ~/.zshrc
curl -fsSL https://raw.githubusercontent.com/run2go/shell/main/zsh/zshenv -o ~/.zshenv
curl -fsSL https://raw.githubusercontent.com/run2go/shell/main/config/vimrc -o ~/.vimrc
curl -fsSL https://raw.githubusercontent.com/run2go/shell/main/config/rc.conf -o ~/.config/ranger/rc.conf

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