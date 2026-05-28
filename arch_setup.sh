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
LOG_FILE="/tmp/arch_setup_$(date +%Y%m%d_%H%M%S).log"
# Splitting standard output (stdout)
exec > >(tee -a "$LOG_FILE")
# Merging standard error (stderr)
exec 2>&1

# Cleanup function for temporary directories
cleanup() {
  echo "Cleaning up temporary directories..."
  rm -rf /tmp/dotfiles
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

read -n 1 -p "Do you want to use Wayland(if no, use i3)? (y/n): " USE_WAYLAND

GITHUB_EMAIL="$1"

# Pre-flight checks
print_section "Pre-flight Checks"
check_command sudo
echo "✓ Prerequisites met"

# ===================================
# System Updates
# ===================================

print_section "Updating the System"
sudo pacman -Syu --noconfirm

# ===================================
# Install Dependencies & Core Tools
# ===================================

print_section "Installing Dependencies"
if [ "$USE_WAYLAND" == 'y' ]; then
  echo -e "\nInstalling Sway"
  sudo pacman -S --needed --noconfirm sway swaybg swaylock waybar wofi wl-clipboard
elif [ "$USE_WAYLAND" == 'n' ]; then
  echo -e "\nInstalling i3wm"
  sudo pacman -S --needed --noconfirm xorg-server xorg-xinit i3-wm polybar i3lock rofi feh xclip
else
  echo -e "\nInvalid option... terminating"
  exit 1
fi

# ===================================
# Install Display Server 
# ===================================

print_section "Installing Applications via Pacman"
sudo pacman -S --needed --noconfirm \
    base-devel git unzip curl pipewire pipewire-pulse wireplumber \
    zsh \
    bat \
    fd \
    ripgrep \
    tree \
    github-cli \
    ranger \
    brightnessctl \
    alacritty \
    neovim \
    btop \
    fzf \
    ttf-jetbrains-mono-nerd \
    openssh \
    firefox

# ===================================
# Download dotfiles 
# ===================================

print_section "Downloading dotfiles"

if [ ! -d "$XDG_CONFIG_HOME/wofi" ] && [ "$USE_WAYLAND" == 'y' ] || [ ! -d "$XDG_CONFIG_HOME/rofi" ] && [ "$USE_WAYLAND" == 'n' ]; then
  mkdir -p "$XDG_CONFIG_HOME"
  rm -rf /tmp/dotfiles
  git clone https://github.com/ben-garcia/dotfiles /tmp/dotfiles
  
  if [ -d "/tmp/dotfiles/config" ]; then
   pushd /tmp/dotfiles/config > /dev/null
  
   shopt -s dotglob
   echo "Syncing configuration files to $XDG_CONFIG_HOME..."
   cp -ar * "$XDG_CONFIG_HOME/"
   shopt -u dotglob
   popd > /dev/null
  else
    echo "Error: 'config' directory not found in the cloned repository." >&2
    exit 1
  fi
  
  if [ -f "$XDG_CONFIG_HOME/wofi/power-menu.sh" ]; then
    chmod +x "$XDG_CONFIG_HOME/wofi/power-menu.sh"
  fi
  
  echo "✓ Dotfiles successfully deployed"
else
  echo "✓ Dotfiles already setup"
fi

# Remove uneccessary configuration files
# When setting up dotfiles, all files are copied to .config directory
if [ "$USE_WAYLAND" == 'y' ]; then
  # remove x11 specific files
  rm -rf $XDG_CONFIG_HOME/i3 $XDG_CONFIG_HOME/polybar $XDG_CONFIG_HOME/rofi
else
  # remove wayland specific files
  rm -rf $XDG_CONFIG_HOME/sway $XDG_CONFIG_HOME/waybar $XDG_CONFIG_HOME/wofi
fi

# ===================================
# Configure Sway (Wayland) & TTY Login
# ===================================

if [ "$USE_WAYLAND" == 'y' ]; then
  print_section "Configuring Sway"

  # Ensure the profile file exists
  mkdir -p "$XDG_CONFIG_HOME/zsh"
  touch "$XDG_CONFIG_HOME/zsh/.zprofile"

  # Configure automatic TTY invocation for Sway (Clean, native Wayland practice)
  if ! grep -q "exec sway" "$XDG_CONFIG_HOME/zsh/.zprofile"; then
    cat << 'EOF' >> "$XDG_CONFIG_HOME/zsh/.zprofile"

  # If running from tty1, automatically launch Sway
  if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
    exec sway
  fi
EOF
    echo "✓ Sway configured to auto-start securely on TTY1 login"
  else
    echo "✓ Sway already configured in .zprofile"
  fi
else
  print_section "Configuring i3"

  echo "exec i3" > $HOME/.xinitrc

  # Ensure the profile file exists
  mkdir -p "$XDG_CONFIG_HOME/zsh"
  touch "$XDG_CONFIG_HOME/zsh/.zprofile"

  # Configure automatic TTY invocation for i3
  if ! grep -q "exec i3" "$XDG_CONFIG_HOME/zsh/.zprofile"; then
    cat << 'EOF' >> "$XDG_CONFIG_HOME/zsh/.zprofile"

  # If running from tty1, automatically launch i3 via startx
  if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
    exec startx
  fi
EOF
    echo "✓ i3 configured to auto-start securely on TTY1 login"
  else
    echo "✓ i3 already configured in .zprofile"
  fi
fi

# ===================================
# Configure Zsh
# ===================================

TARGET_SHELL="/usr/bin/zsh"

if [ "$SHELL" != "$TARGET_SHELL" ]; then
  print_section "Changing Default Shell to Zsh"
  
  if grep -q "^$TARGET_SHELL$" /etc/shells; then
    sudo chsh -s "$TARGET_SHELL" "$USER"
    echo "✓ Default shell changed to Zsh for $USER"
  else
    echo "Error: Zsh path not found in /etc/shells. Skipping shell change." >&2
  fi
fi

if ! grep -q "ZDOTDIR" /etc/zsh/zshenv 2>/dev/null; then
  print_section "Configuring Zsh Environment"

  mkdir -p "$XDG_STATE_HOME/zsh"
  touch "$XDG_STATE_HOME/zsh/zsh_history"

  # Add ZDOTDIR to zshenv
  echo "export ZDOTDIR=$HOME/.config/zsh" | sudo tee -a /etc/zsh/zshenv > /dev/null

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
# Install NVM
# ===================================

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! command -v nvm &> /dev/null; then
  print_section "Installing NVM"

  mkdir -p "$XDG_DATA_HOME/nvm"
  sudo chown -R "$USER:$USER" "$XDG_DATA_HOME/nvm"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

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

if [ ! -d "$NVM_DIR/versions/node" ] || [ -z "$(ls -A "$NVM_DIR/versions/node" 2>/dev/null)" ]; then
  echo "NVM or Node LTS not found. Redownloading cleanly..."
  rm -rf "$NVM_DIR"
  mkdir -p "$NVM_DIR"
  
  curl -q -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash
  
  set +u
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  set -u
fi

NODE_BIN_DIR=$(find "$NVM_DIR/versions/node" -maxdepth 2 -type d -name "bin" | head -n 1)

if [ -z "$NODE_BIN_DIR" ] || [ ! -f "$NODE_BIN_DIR/npm" ]; then
  echo "Error: Could not locate local NVM npm binary." >&2
  exit 1
fi

echo "Forcing script to use NVM binary path: $NODE_BIN_DIR"

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

export PATH="$ORIGINAL_PATH"

# ===================================
# Configure Git
# ===================================

if [ ! -d "$HOME/.ssh" ]; then
  print_section "Configuring Git"

  mkdir -p "$XDG_CONFIG_HOME/git"
  touch "$XDG_CONFIG_HOME/git/config"

  git config --global user.name "$USER"
  git config --global user.email "$GITHUB_EMAIL"

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
# Configure Brightnessctl
# ===================================

print_section "Configuring brightnessctl"
if command -v brightnessctl &> /dev/null; then
  sudo usermod -aG video "$USER"
  echo "✓ Brightnessctl configured"
else
  echo "✓ Brightnessctl not available"
fi

print_section "Configuring audio daemons"

if [ ! -d "$XDG_CONFIG_HOME/systemd" ]; then
  ## Unlike system services, audio servers run on a per-user basis. Do not use sudo for this step.
  systemctl --user enable --now pipewire pipewire-pulse wireplumber
  echo "✓ audio daemons have been configured"
else
  echo "✓ audio daemons already setup"
fi

# ===================================
# Download a wallpaper & Screensaver
# ===================================

if [ ! -f "$HOME/Pictures/wallpaper.jpg" ]; then
  mkdir -p "$HOME/Pictures"
  curl -L -o "$HOME/Pictures/wallpaper.jpg" "http://s1.picswalls.com/wallpapers/2014/02/19/moon-background_111723746_31.jpg" || echo "Warning: Wallpaper download failed"
  echo "✓ Downloaded default wallpaper"
else
  echo "✓ Wallpaper detected"
fi 

if [ ! -f "$HOME/Pictures/screensaver.png" ]; then
  mkdir -p "$HOME/Pictures"
  curl -L -o "$HOME/Pictures/screensaver.png" "https://images2.alphacoders.com/109/1098024.png" || echo "Warning: Screensaver download failed"
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
if [ "$USE_WAYLAND" == 'y' ]; then
  echo "NOTE: if running in a VirtualBox machine AND using Sway(Wayland)"
  echo "   Add the following to the top of $XDG_CONFIG_HOME/zsh/.zprofile"
  echo "      export WLR_RENDERER=pixman"
  echo "      export WLR_NO_HARDWARE_CURSORS=1"
  echo ""
fi
echo "Next steps:"
echo "  1. Manually complete GitHub authentication (see instructions above)"
echo "  2. Reboot or log out, then log into TTY1 to auto-launch Sway/i3."
echo ""
