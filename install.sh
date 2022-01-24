#!/bin/bash

set -e

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

error() {
    printf -- "Error: $*%s\n" >&2  
}

setup_dependencies() {
    printf -- "\nSetting up dependencies:\n\n"  

    # Run apt update
    if command_exists apt; then
        printf -- "Updating apt cache...\n"
        sudo apt-get update && \
        sudo apt-get install --no-install-recommends -y \
        ca-certificates curl file \
        build-essential \
        autoconf automake autotools-dev libtool xutils-dev
    fi

    # Install chezmoi
    if ! [ -x "$(command -v chezmoi)" ]; then
        printf -- "\nInstalling chezmoi:\n\n"  
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install chezmoi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            curl -sfL https://git.io/chezmoi | sh
        fi
    else
        printf -- "\mChezmoi exists, skipping...\n"  
    fi

    # Install zsh
    if ! [ -x "$(command -v zsh)" ]; then
        printf -- "\nInstalling zsh:\n\n"  
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install zsh
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            DEBIAN_FRONTEND=noninteractive sudo apt install -y fonts-powerline zsh
        fi
    else
        printf -- "\mZsh exists, skipping...\n"  
    fi

    # Set zsh as default shell
    if ! [ "$SHELL" = "/bin/zsh" ]; then
        printf -- "\nSetting zsh as default shell:\n\n"  
        if [[ "$OSTYPE" == "darwin"* ]]; then
            chsh -s /bin/zsh
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo chsh -s /usr/bin/zsh "$(whoami)"
        fi
    else
        printf -- "\nZsh is already the default shell, skipping...\n"  
    fi

    # Install sheldon
    if ! [ -x "$(command -v sheldon)" ]; then
        printf -- "\nInstalling sheldon:\n\n"  
        curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
            | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
    else
        printf -- "\nSheldon exists, skipping...\n"  
    fi

    # Install exa
    if ! [ -x "$(command -v exa)" ]; then
        printf -- "\nInstalling exa:\n\n"  
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install exa
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            DEBIAN_FRONTEND=noninteractive sudo apt install -y exa
        fi
    else
        printf -- "\mExa exists, skipping...\n"  
    fi

    # Install bat
    if ! [ -x "$(command -v bat)" ]; then
        printf -- "\nInstalling bat:\n\n"  
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install bat
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            DEBIAN_FRONTEND=noninteractive sudo apt install -y bat
        fi
    else
        printf -- "\mBat exists, skipping...\n"  
    fi
}

finalize_dotfiles() {
    printf -- "\nFinalizing dotfiles:\n\n"  

    printf -- "Updating dotfiles at destination...\n"
        ./bin/chezmoi -v init --apply watemerald
}

main() {
    printf -- "\nDotfiles setup script\n"  

    setup_dependencies
    finalize_dotfiles

    printf -- "\nDone.\n\n"

    # if [ -n "`$SHELL -c 'echo $ZSH_VERSION'`" ]; then
    #    [ -s "$HOME/.zshrc" ] && \. "$HOME/.zshrc"
    # elif [ -n "`$SHELL -c 'echo $BASH_VERSION'`" ]; then
    #    [ -s "$HOME/.bashrc" ] && \. "$HOME/.bashrc"
    # fi
}

main "$@"
