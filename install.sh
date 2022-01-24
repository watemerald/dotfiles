#!/bin/bash

set -e

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

error() {
    printf -- "%sError: $*%s\n" >&2 "$RED" "$RESET"
}

setup_color() {
    # Only use colors if connected to a terminal
    if [ -t 1 ]; then
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        BLUE=$(printf '\033[34m')
        BOLD=$(printf '\033[1m')
        RESET=$(printf '\033[m')
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        BOLD=""
        RESET=""
    fi
}

setup_dependencies() {
    printf -- "\n%sSetting up dependencies:%s\n\n" "$BOLD" "$RESET"

    # Run apt update
    if command_exists apt; then
        printf -- "Updating apt cache...\n"
        sudo apt update
    fi

    # Install chezmoi
    if ! [ -x "$(command -v chezmoi)" ]; then
        printf -- "\n%sInstalling chezmoi:%s\n\n" "$BOLD" "$RESET"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install chezmoi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            curl -sfL https://git.io/chezmoi | sh
        fi
    else
        printf -- "\m%sChezmoi exists, skipping...%s\n" "$YELLOW" "$RESET"
    fi

    # Install zsh
    if ! [ -x "$(command -v zsh)" ]; then
        printf -- "\n%sInstalling zsh:%s\n\n" "$BOLD" "$RESET"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install zsh
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt install zsh
        fi
    else
        printf -- "\m%sZsh exists, skipping...%s\n" "$YELLOW" "$RESET"
    fi

    # Set zsh as default shell
    if ! [ "$SHELL" = "/bin/zsh" ]; then
        printf -- "\n%sSetting zsh as default shell:%s\n\n" "$BOLD" "$RESET"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            chsh -s /bin/zsh
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo chsh -s /bin/zsh
        fi
    else
        printf -- "\m%sZsh is already the default shell, skipping...%s\n" "$YELLOW" "$RESET"
    fi

    # Install sheldon
    if ! [ -x "$(command -v sheldon)" ]; then
        printf -- "\n%sInstalling sheldon:%s\n\n" "$BOLD" "$RESET"
        curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
            | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
    else
        printf -- "\m%sSheldon exists, skipping...%s\n" "$YELLOW" "$RESET"
    fi

    # Install exa
    if ! [ -x "$(command -v exa)" ]; then
        printf -- "\n%sInstalling exa:%s\n\n" "$BOLD" "$RESET"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install exa
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt install exa
        fi
    else
        printf -- "\m%sExa exists, skipping...%s\n" "$YELLOW" "$RESET"
    fi

    # Install bat
    if ! [ -x "$(command -v bat)" ]; then
        printf -- "\n%sInstalling bat:%s\n\n" "$BOLD" "$RESET"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install bat
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt install bat
        fi
    else
        printf -- "\m%sBat exists, skipping...%s\n" "$YELLOW" "$RESET"
    fi
}

finalize_dotfiles() {
    printf -- "\n%sFinalizing dotfiles:%s\n\n" "$BOLD" "$RESET"

    printf -- "%sUpdating dotfiles at destination...%s\n" "$BLUE" "$RESET"
        ./bin/chezmoi -v init --apply watemerald
}

main() {
    printf -- "\n%sDotfiles setup script%s\n" "$BOLD" "$RESET"

    setup_color
    setup_dependencies
    finalize_dotfiles

    printf -- "\n%sDone.%s\n\n" "$GREEN" "$RESET"

    # if [ -n "`$SHELL -c 'echo $ZSH_VERSION'`" ]; then
    #    [ -s "$HOME/.zshrc" ] && \. "$HOME/.zshrc"
    # elif [ -n "`$SHELL -c 'echo $BASH_VERSION'`" ]; then
    #    [ -s "$HOME/.bashrc" ] && \. "$HOME/.bashrc"
    # fi
}

main "$@"
