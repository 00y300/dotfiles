#!/bin/bash

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -q "Pop!_OS" /etc/os-release; then
            echo "PopOS"
        else
            echo "Unsupported Linux distribution"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "MacOS"
    else
        echo "Unsupported OS"
        exit 1
    fi
}

# Function to install Homebrew
install_brew() {
    if ! command -v brew &> /dev/null; then
        if [[ "$1" == "PopOS" ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        elif [[ "$1" == "MacOS" ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        echo "Homebrew is already installed"
    fi
}

# Function to install packages
install_packages() {
    local os=$1
    local failed_packages=()

    while read -r package; do
        if [[ "$os" == "PopOS" ]] && [[ "$package" =~ ^(firefox|maccy|cakebrew|only-switch|stats)$ ]]; then
            echo "Skipping $package on PopOS"
            continue
        fi

        if ! brew install "$package"; then
            failed_packages+=("$package")
        fi
    done < <(brew list -1)

    # Additional installations
    if ! gem install colorls; then
        failed_packages+=("colorls")
    fi

    for package in yazi ffmpegthumbnailer unar jq poppler fd ripgrep fzf zoxide font-symbols-only-nerd-font; do
        if ! brew install "$package"; then
            failed_packages+=("$package")
        fi
    done

    if ! brew install yazi --HEAD; then
        failed_packages+=("yazi --HEAD")
    fi

    # Print failed packages
    if [ ${#failed_packages[@]} -ne 0 ]; then
        echo "Failed to install the following packages:"
        for package in "${failed_packages[@]}"; do
            echo "$package"
        done
    fi
}

# Clone and setup dotfiles
setup_dotfiles() {
    if ! git clone git@github.com:00y300/dotfiles.git; then
        echo "Failed to clone dotfiles repository"
        exit 1
    fi
    cd dotfiles || exit
    if ! stow *; then
        echo "Failed to stow dotfiles"
        exit 1
    fi
    source ~/.zshrc
}

main() {
    os=$(detect_os)
    echo "Detected OS: $os"
    install_brew "$os"
    install_packages "$os"
    setup_dotfiles
}

main
