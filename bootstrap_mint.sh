#!/usr/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# ===================================
# Argument Validation
# ===================================

if [ $# -ne 1 ]; then
    echo "usage: ./$0 <github_email>"
    exit 1
fi

DOTFILES_URL="https://github.com/ben-garcia/dotfiles.git"
PROJECTS_DIR="${HOME}/Projects"
DOTFILES_DIR="${PROJECTS_DIR}/dotfiles"
GITHUB_EMAIL="$1"

# Pre-authenticate sudo to avoid password prompts during script execution
sudo -v

# ===================================
# Configuration and Setup
# ===================================

# Set default XDG directories if not already set
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export NVM_DIR="$XDG_DATA_HOME/nvm"

# Logging
# automatically log all output of a script to a file, while still showing it on the screen
# Format: YYYYMMDD_HHMMSS
LOG_FILE="/tmp/bootstrap_mint_$(date +%Y%m%d_%H%M%S).log"
# Splitting standard output (stdout)
exec > >(tee -a "$LOG_FILE")
# Merging standard error (stderr)
exec 2>&1

# Cleanup function for temporary directories
cleanup() {
    echo "Cleaning up temporary directories..."
    rm -rf /tmp/alacritty /tmp/i3 /tmp/neovim /tmp/btop /tmp/dotfiles
}
# when the program exits, run the cleanup function
trap cleanup EXIT

# ===================================
# Helper Functions
# ===================================

# Function to safely link a configuration directory from dotfiles directory
# @1 app directory
link_directory() {
    # The source directory
    local source="${DOTFILES_DIR}/config/$1"
    # The destination link
    local destination="${XDG_CONFIG_HOME}/$1"
    # The backup directory
    local backup_directory="${XDG_STATE_HOME}/dotfiles_backup"

    # Check if anything exists at the destination path
    if [ -e "$destination" ] || [ -L "$destination" ]; then
        # Check if that existing directory is specifically a symbolic link
        if [ -L "$destination" ]; then
            # Resolve where the existing symlink points to
            local current_target
            current_target=$(readlink "$destination")

            # Idempotency Check: Does it already point to our dotfiles?
            if [ "$current_target" = "$source" ]; then
                echo "[Skipping]:" "$destination is already correctly linked."
                return 0
            else
                echo "[Error]:" "$destination is a symlink, but points to '$current_target' instead of '$source'."
                # Exit for now. Update in the future to create a backup
                # directory to add directory instead of exiting.
                return 1
            fi
        else
            # Make sure the dotfiles backup directory exists
            mkdir -p "$backup_directory"
            local full_backup_path="${backup_directory}/${destination##*/}_$(date +%Y%m%d_%H%M%S)"
            # It's a real directory, so create a backup
            echo "[Backup]:" "Directory already exists at $destination... Creating a backup at $full_backup_path"
            mv "$destination" "$full_backup_path"
        fi
    fi

    # If the destination doesn't exist at all, create the link safely
    echo "[Linking]:" "$destination -> $source"
    # Ensure the parent directory exists (e.g., ~/.config/app/)
    mkdir -p "$(dirname "$destination")"
    ln -s "$source" "$destination"
}

print_section() {
    echo ""
    echo "====================================="
    printf "%-37s\n" "===== $1"
    echo "====================================="
}


# ===================================
# System Updates
# ===================================

print_section "Updating the System"
sudo apt update && sudo apt upgrade -y

# ===================================
# Install Dependencies
# ===================================

print_section "Installing Dependencies"
sudo apt install -y \
    git build-essential pkg-config libfreetype6-dev \
    libfontconfig1-dev meson ninja-build cmake curl \
    gettext libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev \
    libxcb-util0-dev libxcb-icccm4-dev libyajl-dev \
    libstartup-notification0-dev libxcb-randr0-dev libev-dev \
    libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev \
    libxkbcommon-dev libxkbcommon-x11-dev libpcre2-dev \
    libxcb-shape0-dev libxcb-xrm-dev dunst power-profiles-daemon

# ===================================
# Install Applications via APT
# ===================================

print_section "Installing Applications via APT"
sudo apt install -y polybar rofi zsh feh bat fd-find xclip ripgrep tree clangd gh ranger

# ===================================
# Install Alacritty
# ===================================

if ! command -v alacritty &> /dev/null; then
    print_section "Installing Alacritty"

    # Install Rust with auto-accept
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>&1 | head -20
    source "$HOME/.cargo/env"

    # Verify Cargo is available
    if ! command -v cargo &> /dev/null; then
        echo "Error: Cargo installation failed"
        exit 1
    fi

    # Clone and build Alacritty
    git clone https://github.com/alacritty/alacritty.git /tmp/alacritty
    pushd /tmp/alacritty > /dev/null
    echo "Building Alacritty (this may take a few minutes)..."
    cargo build --release 2>&1 | tail -10
    sudo cp target/release/alacritty /usr/local/bin
    sudo cp extra/linux/Alacritty.desktop /usr/share/applications/
    popd > /dev/null

    echo "✓ Alacritty installed"
else
    echo "✓ Alacritty already installed"
fi

# ===================================
# Install i3 Window Manager
# ===================================
if ! command -v i3 &> /dev/null; then
    print_section "Installing i3 Window Manager"

    git clone https://github.com/i3/i3.git /tmp/i3 || exit 1
    pushd /tmp/i3 > /dev/null
    mkdir -p build
    cd build
    meson setup ..
    ninja
    sudo ninja install
    popd > /dev/null

    # Configure .xinitrc
    if [ -f "$HOME/.xinitrc" ]; then
        echo -e "exec i3\nstartx" >> "$HOME/.xinitrc"
    else
        echo -e "exec i3\nstartx" > "$HOME/.xinitrc"
    fi

    # Create i3 desktop entry
    echo -e "[Desktop Entry]\nName=i3\nComment=i3 window manager\nExec=i3\nType=Application\nX-LightDM-Session=i3" \
                                                                                                                 | sudo tee /usr/share/xsessions/i3.desktop > /dev/null
    sudo chmod 644 /usr/share/xsessions/i3.desktop

    echo "✓ i3wm installed"
    echo ""
    echo "IMPORTANT: i3wm requires manual setup:"
    echo "  1. Logout"
    echo "  2. Select i3 desktop environment"
    echo "  3. Login "
else
    echo "✓ i3wm already installed"
fi

# ===================================
# Install Neovim
# ===================================

if ! command -v nvim &> /dev/null; then
    print_section "Installing Neovim"

    git clone https://github.com/neovim/neovim /tmp/neovim || exit 1
    pushd /tmp/neovim > /dev/null
    git checkout stable
    make CMAKE_BUILD_TYPE=Release
    sudo make install
    popd > /dev/null

    echo "✓ Neovim installed"
else
    echo "✓ Neovim already installed"
fi

# ===================================
# Install Btop
# ===================================

if ! command -v btop &> /dev/null; then
    print_section "Installing Btop"

    # Check g++ version and upgrade if necessary
    GCC_VERSION=$(g++ --version | grep -oE '[0-9]+(\.[0-9]+)+' | head -n1 | cut -d. -f1)

    if [ "$GCC_VERSION" -le 13 ]; then
        echo "Upgrading g++ from version $GCC_VERSION to 14..."
        sudo apt install -y gcc-14 g++-14
        sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 10 --quiet
        sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 20 --quiet
        sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 10 --quiet
        sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-14 20 --quiet
    fi

    git clone https://github.com/aristocratos/btop.git /tmp/btop || exit 1
    pushd /tmp/btop > /dev/null
    make
    sudo make install
    popd > /dev/null

    echo "✓ Btop installed"
else
    echo "✓ Btop already installed"
fi

# ===================================
# Configure Zsh
# ===================================

# 1. Always ensure your user's shell is set to Zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    print_section "Changing Default Shell to Zsh"
    # Passing $USER explicitly ensures your user profile changes, even when run with sudo mechanics
    sudo chsh -s "$(which zsh)" "$USER"
    echo "✓ Default shell changed to Zsh for $USER"
fi

# 2. Configure system-wide ZDOTDIR if not already done
if ! grep -q "ZDOTDIR" /etc/zsh/zshenv 2> /dev/null; then
    print_section "Configuring Zsh Environment"

    mkdir -p "$XDG_STATE_HOME/zsh"
    touch "$XDG_STATE_HOME/zsh/zsh_history"

    # Add ZDOTDIR to zshenv
    echo "export ZDOTDIR=$HOME/.config/zsh" | sudo tee -a /etc/zsh/zshenv > /dev/null

    # Install zsh plugins
    git clone https://github.com/jeffreytse/zsh-vi-mode.git \
        "$XDG_DATA_HOME/zsh/plugins/zsh-vi-mode" 2> /dev/null || true
    git clone https://github.com/zsh-users/zsh-autosuggestions.git \
        "$XDG_DATA_HOME/zsh/plugins/zsh-autosuggestions" 2> /dev/null || true
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$XDG_DATA_HOME/zsh/plugins/zsh-syntax-highlighting" 2> /dev/null || true
    git clone https://github.com/Aloxaf/fzf-tab.git \
        "$XDG_DATA_HOME/zsh/plugins/fzf-tab" 2> /dev/null || true

    echo "✓ Zsh configured and plugins installed"
else
    echo "✓ Zsh plugins and ZDOTDIR environment already configured"
fi

# ===================================
# Install JetBrains Mono Nerd Font
# ===================================

if [ ! -d "/usr/share/fonts/truetype/jetbrains-mono" ]; then
    print_section "Installing JetBrains Mono Nerd Font"

    sudo mkdir -p /usr/share/fonts/truetype/jetbrains-mono
    pushd /usr/share/fonts/truetype/jetbrains-mono > /dev/null
    sudo curl -fLo "JetBrainsMonoNerdFont.zip" \
        https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
    sudo unzip -o "JetBrainsMonoNerdFont.zip"
    sudo rm "JetBrainsMonoNerdFont.zip"
    sudo fc-cache -fv
    popd > /dev/null

    echo "✓ JetBrains Mono Nerd Font installed"
else
    echo "✓ JetBrains Mono Nerd Font already installed"
fi

# ===================================
# Install FZF
# ===================================

if ! command -v fzf &> /dev/null; then
    print_section "Installing FZF"

    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" || true

    # Added --all to answer "yes" to all prompts automatically
    "$HOME/.fzf/install" --no-update-rc --all

    sudo ln -sf "$HOME/.fzf/bin/fzf" /usr/bin/fzf

    echo "✓ FZF installed"
else
    echo "✓ FZF already installed"
fi

# ===================================
# Install NVM
# ===================================

# source nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

if ! command -v nvm &> /dev/null; then
    print_section "Installing NVM"

    mkdir -p "$XDG_DATA_HOME/nvm"
    sudo chown -R "$USER:$USER" "$XDG_DATA_HOME/nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

    echo "✓ NVM installed"
else
    echo "✓ NVM already installed"
fi

if ! command -v npm &> /dev/null; then
    print_section "Installing Npm(LTS)"
    nvm install --lts
    echo "✓ Npm installed(LTS)"
else
    echo "✓ Npm already installed"
fi

# ===================================
# Install Language Servers
# ===================================

print_section "Installing Language Servers"

servers=("stylelint-lsp" "typescript-language-server")
for server in "${servers[@]}"; do
    if ! command -v $server; then
        npm install -g $server
    else
        echo "✓ $server is already installed"
    fi
done

if ! command -v vscode-css-language-server; then
    npm i -g vscode-langservers-extracted
    echo "✓ vscode-langservers installed"
else
    echo "✓ vscode-langservers already installed"
fi

# ===================================
# Configure Git
# ===================================

if [ ! -d $HOME/.ssh ]; then
    print_section "Configuring Git"

    mkdir -p "$XDG_CONFIG_HOME/git"
    touch "$XDG_CONFIG_HOME/git/config"

    # Configure git user
    git config --global user.name "$USER"
    git config --global user.email "$GITHUB_EMAIL"

    # Generate SSH key
    ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f "$HOME/.ssh/id_ed25519" -N "" || true

    echo "✓ Git configured"
    echo ""
    echo "IMPORTANT: GitHub authentication still requires manual setup:"
    echo "  1. Run: gh auth login"
    echo "  2. Run: gh ssh-key add $HOME/.ssh/id_ed25519.pub --type signing"
    echo "  3. Test: ssh -T git@github.com"
else
    echo "✓ Git already configured"
fi

# ===================================
# Configure Bat and Brightnessctl
# ===================================

print_section "Configuring Bat and Brightnessctl"

# Bat
if ! [ -L /usr/bin/bat ]; then
    # Find the absolute path of batcat safely
    if BATCAT_PATH=$(command -v batcat); then
        sudo ln -sf "$BATCAT_PATH" /usr/bin/bat
    else
        echo "Error: 'batcat' executable not found in PATH." >&2
        exit 1
    fi
fi

# Brightnessctl
if ! command -v brightnessctl; then
    sudo usermod -aG video "$USER"
    echo "✓ Brightnessctl configured"
else
    echo "✓ Brightnessctl already configured"
fi

# ===================================
# Download dotfiles
# ===================================

if [ ! -d "${PROJECTS_DIR}/dotfiles" ]; then
    echo "Dotfiles configuration"

    wayland_only_apps=("sway" "waybar" "wofi")

    # Make sure the config folder exists
    mkdir -p "$XDG_CONFIG_HOME"
    # Clone the repo to the Projects directory
    git clone "$DOTFILES_URL" "${PROJECTS_DIR}/dotfiles"
    cd "${DOTFILES_DIR}/config"

    # Loop through the dotfiles config directory
    for directory in *; do
        if [[ " ${wayland_only_apps[*]} " =~ " ${directory} " ]]; then
            # Ignore wayland apps
            continue
    fi

    # link_directory "${DOTFILES_DIR}/config/$directory" "${XDG_CONFIG_HOME}/$directory"
    link_directory "$directory"
done

    # Configure dotfiles scripts
    user_scripts_directory="$HOME/.local/bin"
    scripts_directory="${DOTFILES_DIR}/scripts"

    echo "Dotfiles scripts"

    mkdir -p "$user_scripts_directory"
    cd "$scripts_directory"

    for script in *; do
        if [[ ! -x "${user_scripts_directory}/${script}" ]]; then
            # Remove the .sh extension (e.g. power-menu.sh -> power-menu)
            binary="${user_scripts_directory}/${script%%.*}"

            echo "[Linking]: ${binary} -> ${scripts_directory}/${script}"
            chmod +x "$script"
            ln -s "${scripts_directory}/${script}" "$binary"
    else
            echo "[Skipping]: ${scripts_directory}/${script} is already correctly linked."
    fi
done

    echo "Dotfiles successfully configured"
else
    cd "${PROJECTS_DIR}/dotfiles"
    git pull
    echo "Dotfiles already configured... Pulled the latest changes"
fi

# ===================================
# Configure daemons
# ===================================

print_section "Configuring Daemons"

# Check dunst safely (stores "active", "inactive", or "unknown")
dunst_status=$(systemctl --user is-active dunst || echo "inactive")

if [ "$dunst_status" != "active" ]; then
    systemctl --user enable --now dunst
    echo "✓ dunst configured"
else
    echo "✓ dunst is already running"
fi

# Check power-profiles-daemon safely
power_profiles_status=$(sudo systemctl is-active power-profiles-daemon || echo "inactive")

if [ "$power_profiles_status" != "active" ]; then
    sudo systemctl enable --now power-profiles-daemon
    echo "✓ power-profiles-daemon configured"
else
    echo "✓ power-profiles-daemon is already running"
fi

# ===================================
# Download a wallpaper
# ===================================

if [ ! -f $HOME/Pictures/wallpaper.jpg ]; then
    curl -o $HOME/Pictures/wallpaper.jpg http://s1.picswalls.com/wallpapers/2014/02/19/moon-background_111723746_31.jpg
    curl -L -o $HOME/Pictures/wallpaper.jpg "http://s1.picswalls.com/wallpapers/2014/02/19/moon-background_111723746_31.jpg"
    echo "✓ Downloaded default wallpaper"
else
    echo "✓ Wallpaper detected"
fi

# ===================================
# Download a screensaver
# ===================================

if [ ! -f $HOME/Pictures/screensaver.png ]; then
    curl -L -o $HOME/Pictures/screensaver.png https://images2.alphacoders.com/109/1098024.png
    echo "✓ Downloaded default screensaver"
else
    echo "✓ Screensaver detected"
fi

# ===================================
# Installation Complete
# ===================================

print_section "Installation Complete"
echo ""
echo "Setup log saved to: $LOG_FILE"
echo ""
echo "Next steps:"
echo "  1. Manually complete GitHub authentication (see above)"
echo "  2. Manually change desktop environment  (see above)"
echo "  3. Manually download a wallpaper(jpg) and screensaver(png) to Pictures directory"
echo "  4. Log out and back in for group changes to take effect"
echo "  5. Configure your shell and text editor as needed"
echo ""
