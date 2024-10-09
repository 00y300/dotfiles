#!/bin/bash

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "MacOS"
    else
        echo "Unsupported OS"
        exit 1
    fi
}

# Function to install Homebrew
install_brew() {
    if ! command -v brew &> /dev/null; then
        if [[ "$1" == "MacOS" ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        echo "Homebrew is already installed"
    fi
}

# Function to install packages and casks for MacOS
install_packages() {
    local failed_packages=()

    # Install Formulae (updated list)
    formulae=(
        stow tmux neovim fd ripgrep fzf lazygit zoxide lua luajit ruby
        luarocks starship node
    )

    for package in "${formulae[@]}"; do
        if ! brew install "$package"; then
            failed_packages+=("$package")
        fi
    done

    # Install Casks
    casks=(
        battery miniconda chatgpt only-switch font-hurmit-nerd-font
        quarto kitty zen-browser
    )

    for cask in "${casks[@]}"; do
        if ! brew install --cask "$cask"; then
            failed_packages+=("$cask")
        fi
    done

    # Print failed packages
    if [ ${#failed_packages[@]} -ne 0 ]; then
        echo "Failed to install the following packages:"
        for package in "${failed_packages[@]}"; do
            echo "$package"
        done
    fi
}

# Clone and setup dotfiles (using SSH for git clone)
setup_dotfiles() {
    if ! git clone git@github.com:00y300/dotfiles.git; then
        echo "Failed to clone dotfiles repository"
        exit 1
    fi
    cd dotfiles || exit
    if ! stow .; then
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
