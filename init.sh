#!/bin/sh

# Function to get the current shell
get_current_shell() {
    local current_shell
    current_shell=$($(which ps) -p $$ -o 'comm=')
    echo $current_shell
}

# Function to get the parent shell
get_parent_shell() {
    local parent_pid
    parent_pid=$(ps -p $$ -o ppid=)
    ps -p $parent_pid -o comm=
}
# Function to check ANSI escape code support
supports_ansi() {
    # Assuming modern shells support ANSI
    case "$1" in
        bash|zsh|ksh|ash)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

update_sh() {
    install_dependencies curl

    # Load latest shrc file
    curl -fsSL https://raw.githubusercontent.com/run2go/shell/HEAD/sh/shrc -o ~/.shrc

    # Decide on machine type
    case $detected_user in
        1)  prompt_user='<'$(whoami)'>' ;; #root
        2)  prompt_user=$(whoami) ;; #user
        *)  echo "Invalid user: '$detected_user'"
            exit 1 ;;
    esac

    # Construct new prompt
    prompt='[$(date "+%T")] '$prompt_user'@$(hostname):$(pwd) '$prompt_symbol' '
    
    # Update PS1 prompt in shrc file
    sed -i "0,/^PS1='.*'/s//PS1='$prompt'/" ~/.shrc

    . ~/.shrc
}

update_bash() {
    install_dependencies curl bash vim sudo sed jq git htop

    # Load vimrc config
    curl -fsSL https://raw.githubusercontent.com/run2go/shell/HEAD/config/vimrc -o ~/.vimrc

    # Load latest bashrc file
    curl -fsSL https://raw.githubusercontent.com/run2go/shell/HEAD/bash/bashrc -o ~/.bashrc
    
    # Decide on machine type
    case $detected_user in
        1)  prompt_user='\\[\\e[0;1;38;5;197m\\]' ;; #root
        2)  prompt_user='\\[\\e[0;1;38;5;209m\\]' ;; #user
        *)  echo "Invalid user: '$detected_user'"
            exit 1 ;;
    esac

    # Decide on user type
    case $desired_machine in
        1)  prompt_host='\\[\\e[0;1;38;5;113m\\]' ;; #local
        2)  prompt_host='\\[\\e[0;1;38;5;153m\\]' ;; #quick
        3)  prompt_host='\\[\\e[0;1;38;5;183m\\]' ;; #temp
        4)  prompt_host='\\[\\e[0;1;38;5;211m\\]' ;; #test
        5)  prompt_host='\\[\\e[0;1;38;5;215m\\]' ;; #dev
        6)  prompt_host='\\[\\e[0;1;38;5;203m\\]' ;; #prod
        7)  prompt_host='\\[\\e[0;1;38;5;197m\\]' ;; #host
        *)  echo "Invalid machine: '$desired_machine'"
            exit 1 ;;
    esac

    # Construct new prompt
    prompt='\\[\\e[2m\\][\\t] '$prompt_user'\\u\\[\\e[0;2m\\]@\\[\\e[0;2m\\]'$prompt_host'\\H\\[\\e[0;2m\\]:\\[\\e[0;38;5;105m\\]\\w\\[\\e[0m\\] '$prompt_host''$prompt_symbol' \\[\\e[0m\\]'
    
    # Update PS1 prompt in bashrc file
    sed -i "0,/^DEFAULT_PROMPT='.*'/s//DEFAULT_PROMPT='$prompt'/" ~/.bashrc

    # Execute bashrc file
    source ~/.bashrc
}

check_installed() {
    for pkg in "$@"; do
        if [ -x "$(command -v apk)" ]; then
            apk info "$pkg" > /dev/null 2>&1
        elif [ -x "$(command -v dpkg)" ]; then
            dpkg -s "$pkg" > /dev/null 2>&1
        elif [ -x "$(command -v rpm)" ]; then
            rpm -q "$pkg" > /dev/null 2>&1
        elif [ -x "$(command -v pacman)" ]; then
            pacman -Qi "$pkg" > /dev/null 2>&1
        elif [ -x "$(command -v zypper)" ]; then
            zypper se -i "$pkg" > /dev/null 2>&1
        else
            return 1
        fi
        
        if [ $? -ne 0 ]; then
            return 1
        fi
    done
    return 0
}

install_dependencies() {
    # Filter out already installed packages
    packages_to_install=""
    for pkg in "$@"; do
        if ! check_installed "$pkg"; then
            packages_to_install="$packages_to_install $pkg"
        fi
    done

    if [ -x "$(command -v apk)" ]; then
        if [ "$(id -u)" -eq 0 ]; then
            apk add --quiet --no-progress --no-cache $packages_to_install
        else
            sudo apk add --quiet --no-progress --no-cache $packages_to_install
        fi
    elif [ -x "$(command -v apt-get)" ]; then
        if [ "$(id -u)" -eq 0 ]; then
            apt-get -qq -y install $packages_to_install
        else
            sudo apt-get -qq -y install $packages_to_install
        fi
    elif [ -x "$(command -v dnf)" ]; then
        if [ "$(id -u)" -eq 0 ]; then
            dnf -q -y install $packages_to_install
        else
            sudo dnf -q -y install $packages_to_install
        fi
    elif [ -x "$(command -v pacman)" ]; then
        if [ "$(id -u)" -eq 0 ]; then
            pacman --noconfirm --quiet -S $packages_to_install
        else
            sudo pacman --noconfirm --quiet -S $packages_to_install
        fi
    elif [ -x "$(command -v zypper)" ]; then
        if [ "$(id -u)" -eq 0 ]; then
            zypper install -q -n $packages_to_install
        else
            sudo zypper install -q -n $packages_to_install
        fi
    else
        echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: '$packages_to_install'" >&2
    fi
}

# Create placeholder prompt
prompt="~> "

# Use transfer parameter if provided
desired_machine=$1

# Determine if user is root
if [ "$(id -u)" -eq 0 ]; then
    detected_user=1
else
    detected_user=2
fi

# Determine the parent shell
parent_shell=$(get_parent_shell)

# Check for ANSI escape code support
if supports_ansi "$parent_shell"; then
    prompt_selection="Select your target machine (1-7):\n\n
    (1) \e[0;1;38;5;113m local \t (green) \t ❯  \e[0m \n
    (2) \e[0;1;38;5;153m quick \t (blue) \t ›   \e[0m \n
    (3) \e[0;1;38;5;183m temp  \t (purple) \t »   \e[0m \n
    (4) \e[0;1;38;5;211m test  \t (rose) \t ⋙   \e[0m \n
    (5) \e[0;1;38;5;215m dev   \t (yellow) \t ⫺   \e[0m \n
    (6) \e[0;1;38;5;203m prod  \t (orange) \t ⪢   \e[0m \n
    (7) \e[0;1;38;5;197m host  \t (red) \t\t ⫸  \e[0m \n
    "
else
    prompt_selection="Select your target machine:\n\n
    (1) local \t    (green)  \t ❯ \n
    (2) quick \t    (blue) \t › \n
    (3) temp \t     (purple) \t » \n
    (4) test \t     (rose) \t ⋙ \n
    (5) dev \t      (yellow) \t ⫺ \n
    (6) prod \t     (orange) \t ⪢ \n
    (7) host \t     (red)  \t\t ⫸ \n
    "
fi

# Determine machine type if missing $1
while [ -z "$desired_machine" ]; do
    clear
    echo $prompt_selection
    read -r desired_machine < /dev/tty

    # Check if input is numeric
    case $desired_machine in
        ''|*[!1-7]*) 
            desired_machine=""
            clear
            ;;
    esac
done

# Assign prompt_symbol
case $desired_machine in
    1) prompt_symbol='❯' ;; #local
    2) prompt_symbol='›' ;; #quick
    3) prompt_symbol='»' ;; #temp
    4) prompt_symbol='⋙ ' ;; #test
    5) prompt_symbol='⫺' ;; #dev
    6) prompt_symbol='⪢' ;; #prod
    7) prompt_symbol='⫸' ;; #host
    *) echo "Invalid user: '$1'" ;;
esac


# Check for ANSI escape code support
if supports_ansi "$parent_shell"; then
    update_bash
else
    update_sh
fi



# Overwrite default profile file
wget -q https://raw.githubusercontent.com/run2go/shell/HEAD/config/profile -O ~/.profile

# Aqcuire latest aliases file
wget -q https://raw.githubusercontent.com/run2go/shell/HEAD/config/aliases -O ~/.aliases

# Export PS1 to ensure it is applied
export PS1="$prompt"

# Start a new shell with the updated settings
exec $parent_shell

