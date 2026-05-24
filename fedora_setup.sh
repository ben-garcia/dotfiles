#!/usr/bin/bash

# Exit on error, undefined variables, and pipe failures
set -e
set -u
set -o pipefail

# ===================================
# Argument Validation
# ===================================

if [ $# -ne 1 ]; then
  echo "usage: ./$0 <github_email>"
  exit 1
fi

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
LOG_FILE="/tmp/fedora_setup_$(date +%Y%m%d_%H%M%S).log"
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

print_section() {
  echo ""
  echo "====================================="
  printf "%-37s\n" "===== $1"
  echo "====================================="
}

check_command() {
  if ! command -v "$1" &> /dev/null; then
    echo "Error: $1 is required but not installed."
    exit 1
  fi
}

GITHUB_EMAIL="$1"

# Pre-flight checks
print_section "Pre-flight Checks"
check_command sudo
echo "✓ Prerequisites met"

# ===================================
# System Updates
# ===================================

print_section "Updating the System"
sudo dnf upgrade --refresh -y

# ===================================
# Install Dependencies
# ===================================

print_section "Installing Dependencies"

# Install Fedora development tools group and essential compilation libraries
sudo dnf install -y @development-tools

# ===================================
# Install Applications via DNF
# ===================================

print_section "Installing Applications via DNF"
# Note: 'fd-find' binary is called 'fd' natively in Fedora, 'bat' is called 'bat'
sudo dnf install -y \
	polybar \
	rofi \
	zsh \
	feh \
	bat \
	fd-find \
	xclip \
	ripgrep \
	tree \
	gh \
	ranger \
	gcc-c++ \
	brightnessctl \
	alacritty \
	i3 \
	neovim \
	btop \
	fzf \
	lightdm \
	lightdm-gtk-greeter

# ===================================
# Configure i3
# ===================================

print_section "Configuring i3"

if [ ! -f "$HOME/.xinitrc" ]; then
  echo -e "exec i3\nstartx" > "$HOME/.xinitrc"
  sudo systemctl enable lightdm.service -f
  echo -e "✓ i3 has been configured"
else
  echo -e "✓ i3 already configured"
fi

# ===================================
# Configure Zsh
# ===================================

# 1. Always ensure your user's shell is set to Zsh safely
TARGET_SHELL="/usr/bin/zsh"

if [ "$SHELL" != "$TARGET_SHELL" ]; then
  print_section "Changing Default Shell to Zsh"
  
  # Double-check that our target path is actually valid and registered
  if grep -q "^$TARGET_SHELL$" /etc/shells; then
    sudo chsh -s "$TARGET_SHELL" "$USER"
    echo "✓ Default shell changed to Zsh for $USER"
  elif grep -q "/zsh" /etc/shells; then
    # Fallback to whatever Zsh path is registered in /etc/shells
    REGISTERED_ZSH=$(grep "/zsh" /etc/shells | head -n 1)
    sudo chsh -s "$REGISTERED_ZSH" "$USER"
    echo "✓ Default shell changed to Zsh ($REGISTERED_ZSH) for $USER"
  else
    echo "Error: Zsh is installed but not found in /etc/shells. Skipping shell change." >&2
  fi
fi

# 2. Configure system-wide ZDOTDIR if not already done
if ! grep -q "ZDOTDIR" /etc/zshenv 2>/dev/null; then
  print_section "Configuring Zsh Environment"

  sudo mkdir -p /etc/zsh
  mkdir -p "$XDG_STATE_HOME/zsh"
  touch "$XDG_STATE_HOME/zsh/zsh_history"

  # Add ZDOTDIR to zshenv
  echo "export ZDOTDIR=$HOME/.config/zsh" | sudo tee -a /etc/zshenv > /dev/null

  # Install zsh plugins
  git clone https://github.com/jeffreytse/zsh-vi-mode.git \
    "$XDG_DATA_HOME/zsh/plugins/zsh-vi-mode" 2>/dev/null || true
  git clone https://github.com/zsh-users/zsh-autosuggestions.git \
    "$XDG_DATA_HOME/zsh/plugins/zsh-autosuggestions" 2>/dev/null || true
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$XDG_DATA_HOME/zsh/plugins/zsh-syntax-highlighting" 2>/dev/null || true
  git clone https://github.com/Aloxaf/fzf-tab.git \
    "$XDG_DATA_HOME/zsh/plugins/fzf-tab" 2>/dev/null || true

  echo "✓ Zsh configured and plugins installed"
else
  echo "✓ Zsh plugins and ZDOTDIR environment already configured"
fi

# ===================================
# Install JetBrains Mono Nerd Font
# ===================================

if [ ! -d "/usr/share/fonts/jetbrains-mono" ]; then
  print_section "Installing JetBrains Mono Nerd Font"

  # Fedora prefers global manual fonts inside /usr/share/fonts/ or ~/.local/share/fonts/
  sudo mkdir -p /usr/share/fonts/jetbrains-mono
  pushd /usr/share/fonts/jetbrains-mono > /dev/null
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
# Install NVM
# ===================================

# source nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

if ! command -v nvm &> /dev/null; then
  print_section "Installing NVM"

  mkdir -p "$XDG_DATA_HOME/nvm"
  sudo chown -R "$USER:$USER" "$XDG_DATA_HOME/nvm"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

  # Load NVM into the current script process immediately
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  # Temporarily drop strictness to let NVM install Node safely
  set +u
  echo "Downloading and installing Node LTS via NVM..."
  nvm install --lts
  nvm alias default 'lts/*'
  set -u

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

export NVM_DIR="$XDG_DATA_HOME/nvm"

# 1. Freshly install NVM & Node LTS if NVM directory doesn't exist or is empty
if [ ! -d "$NVM_DIR/versions/node" ] || [ -z "$(ls -A "$NVM_DIR/versions/node" 2>/dev/null)" ]; then
  echo "NVM or Node LTS not found. Redownloading cleanly..."
  rm -rf "$NVM_DIR"
  mkdir -p "$NVM_DIR"
  
  # Run installer without profile injection to keep it clean
  curl -q -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash
  
  # Force an explicit LTS installation using a clean subshell environment
  set +u
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  set -u
fi

# 2. Extract the exact binary path to NVM's Node execution folder
# This bypasses the need for 'nvm use' or shell functions entirely!
NODE_BIN_DIR=$(find "$NVM_DIR/versions/node" -maxdepth 2 -type d -name "bin" | head -n 1)

if [ -z "$NODE_BIN_DIR" ] || [ ! -f "$NODE_BIN_DIR/npm" ]; then
  echo "Error: Could not locate local NVM npm binary." >&2
  exit 1
fi

echo "Forcing script to use NVM binary path: $NODE_BIN_DIR"

# 3. Temporarily prepend NVM's local Node directory to the script's PATH
# This ensures that standard 'npm' commands run from your local user profile safely
ORIGINAL_PATH="$PATH"
export PATH="$NODE_BIN_DIR:$PATH"

servers=("stylelint-lsp" "typescript-language-server")
for server in "${servers[@]}"
do
  if ! "$NODE_BIN_DIR/npm" list -g "$server" &> /dev/null; then
    npm install -g "$server"
    echo "✓ $server installed"
  else
    echo "✓ $server is already installed"
  fi
done

if ! "$NODE_BIN_DIR/npm" list -g vscode-langservers-extracted &> /dev/null; then
  npm install -g vscode-langservers-extracted
  echo "✓ vscode-langservers installed"
else
  echo "✓ vscode-langservers already installed"
fi

# Restore original path setup safely
export PATH="$ORIGINAL_PATH"

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

# Bat logic cleaned up because Fedora uses the binary name 'bat' outright.
if ! command -v bat &> /dev/null; then
  echo "Error: 'bat' executable not found in PATH." >&2
  exit 1
fi

# Brightnessctl (group assignment remains valid on Fedora)
if command -v brightnessctl &> /dev/null; then
  sudo usermod -aG video "$USER"
  echo "✓ Brightnessctl configured"
else
  echo "✓ Brightnessctl not available"
fi

# ===================================
# Download dotfiles 
# ===================================

if [ ! -d "$XDG_CONFIG_HOME/rofi" ]; then
  print_section "Downloading dotfiles"
  
  # Ensure target directory exists
  mkdir -p "$XDG_CONFIG_HOME"
  
  # Clean up any lingering partial clones before cloning
  rm -rf /tmp/dotfiles
  git clone https://github.com/ben-garcia/dotfiles /tmp/dotfiles
  
  if [ -d "/tmp/dotfiles/config" ]; then
   pushd /tmp/dotfiles/config > /dev/null
  
   # Use dotglob so wilcards capture hidden assets gracefully
   shopt -s dotglob

   echo "Syncing configuration files to $XDG_CONFIG_HOME..."
   # -a preserves attributes (permissions/timestamps), -r copies recursively
   # This safely merges files into existing directories without wiping them out
   cp -ar * "$XDG_CONFIG_HOME/"

   shopt -u dotglob
   popd > /dev/null
  else
    echo "Error: 'config' directory not found in the cloned repository." >&2
    exit 1
  fi
  
  if [ -f "$XDG_CONFIG_HOME/rofi/power-menu.sh" ]; then
    chmod +x "$HOME/.config/rofi/power-menu.sh"
  fi
  
  echo "✓ Dotfiles downloaded successfully deplayed"
else
  echo "✓ Dotfiles already setup"
fi

# ===================================
# Download a wallpaper
# ===================================

if [ ! -f $HOME/Pictures/wallpaper.jpg ]; then
  mkdir -p $HOME/Pictures
  curl -L -o $HOME/Pictures/wallpaper.jpg "http://s1.picswalls.com/wallpapers/2014/02/19/moon-background_111723746_31.jpg" || echo "Warning: Wallpaper download failed"
  echo "✓ Downloaded default wallpaper"
else
  echo "✓ Wallpaper detected"
fi 

# ===================================
# Download a screensaver
# ===================================

if [ ! -f $HOME/Pictures/screensaver.png ]; then
  mkdir -p $HOME/Pictures
  curl -L -o $HOME/Pictures/screensaver.png "https://images2.alphacoders.com/109/1098024.png" || echo "Warning: Screensaver download failed"
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
echo "  3. Log out and back in for group changes to take effect"
echo "  4. Configure your shell and text editor as needed"
echo ""
