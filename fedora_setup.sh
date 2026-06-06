#!/usr/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
RESET="\e[0m"

GITHUB_EMAIL="7rubengarcia7@gmail.com"
DOTFILES_URL="https://github.com/ben-garcia/dotfiles.git"
PROJECTS_DIR="${HOME}/Projects"
DOTFILES_DIR="${PROJECTS_DIR}/dotfiles"

# Pre-authenticate sudo
sudo -v

# ===================================
# Configuration and Setup
# ===================================

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export NVM_DIR="$XDG_DATA_HOME/nvm"

LOG_FILE="/tmp/fedora_setup_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

# Function to output successful message
# @1 green text
# @2 text
log_info() {
    echo -e "${GREEN}$1${RESET} $2"
}

# Function to output an error message before exiting
# @1 red text
# @2 text
log_error() {
    echo -e "${RED}$1${RESET} $2"
}

# Function to output information text
# @1 yellow text
# @2 text
log_warn() {
    echo -e "${YELLOW}$1${RESET} $2"
}

# Function to safely link a configuration directory from dotfiles directory
# @1 source path
# @2 target path
link_directory() {
    # The source directory
    local source="$1"
    # The destination link
    local destination="$2"
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
                log_warn "[Skipping]:" "$destination is already correctly linked."
                return 0
            else
                log_error "[Error]:" "$destination is a symlink, but points to '$current_target' instead of '$source'."
                # Exit for now. Update in the future to create a backup
                # directory to add directory instead of exiting.
                return 1
            fi
        else
            # Make sure the dotfiles backup directory exists
            mkdir -p "$backup_directory"
            local full_backup_path="${backup_directory}/${destination##*/}_$(date +%Y%m%d_%H%M%S)"
            # It's a real directory, so create a backup
            log_warn "[Backup]:" "Directory already exists at $destination... Creating a backup at $full_backup_path"
            mv "$destination" "$full_backup_path"
        fi
    fi

    # If the destination doesn't exist at all, create the link safely
    log_info "[Linking]:" "$destination -> $source"
    # Ensure the parent directory exists (e.g., ~/.config/app/)
    mkdir -p "$(dirname "$destination")"
    ln -s "$source" "$destination"
}

# Function to install any upgrade and core tools
update_system() {
    log_info "[Bootstrap]:" "Updating the system"

    sudo dnf upgrade --refresh -y

    if [[ $USE_WAYLAND == 'y' ]]; then
        log_info "[Installing]:" "Sway suite"
        sudo dnf install -y sway swaybg swaylock waybar wofi wl-clipboard
    else
        log_info "[Installing]:" "i3 suite"
        sudo dnf install -y xorg-x11-server-Xorg xorg-x11-xinit i3 polybar i3lock rofi feh xclip
    fi

    log_info "[Installing]:" "Applications"

    sudo dnf install -y @development-tools unzip \
        zsh bat fd-find ripgrep tree gh ranger gcc-c++ \
        brightnessctl alacritty neovim btop fzf \
        dunst shfmt shellcheck

    # Remove tuned in favor of power-profiles-daemon
    sudo dnf install -y --allowerasing power-profiles-daemon
}

# Configure dotfiles
configure_dotfiles() {
    if [ ! -d "${PROJECTS_DIR}/dotfiles" ]; then
        log_info "[Bootstrap]:" "Dotfiles configuration"

        wayland_only_apps=("sway" "waybar" "wofi")
        x11_only_apps=("i3" "polybar" "rofi")

        # Make sure the config folder exists
        mkdir -p "$XDG_CONFIG_HOME"
        # Clone the repo to the Projects directory
        git clone "$DOTFILES_URL" "${PROJECTS_DIR}/dotfiles"
        cd "${DOTFILES_DIR}/config"

        # Loop through the dotfiles config directory
        for directory in *; do
            if { [ "$USE_WAYLAND" == "y" ] && [[ " ${x11_only_apps[*]} " =~ " ${directory} " ]]; } ||
               { [ "$USE_WAYLAND" == "n" ] && [[ " ${wayland_only_apps[*]} " =~ " ${directory} " ]]; }; then
                # Ignore wayland apps on an x11 system and
                # ignore x11 apps on a wayland system
                continue
            fi

            link_directory "${DOTFILES_DIR}/config/$directory" "${XDG_CONFIG_HOME}/$directory"
        done

        # Configure dotfiles scripts
        user_scripts_directory="$HOME/.local/bin"
        scripts_directory="${DOTFILES_DIR}/scripts"

        log_info "[Configuring]:" "Dotfiles scripts"

        mkdir -p "$user_scripts_directory"
        cd "$scripts_directory"

        for script in *; do
            if [[ ! -x "${user_scripts_directory}/${script}" ]]; then
                # Remove the .sh extension (e.g. power-menu.sh -> power-menu)
                binary="${user_scripts_directory}/${script%%.*}"

                log_info "[Linking]:" "${binary} -> ${scripts_directory}/${script}"
                chmod +x "$script"
                ln -s "${scripts_directory}/${script}" "$binary"
            else
                log_warn "[Skipping]:" "${scripts_directory}/${script} is already correctly linked."
            fi
        done

        log_info "✓ Dotfiles successfully configured" ""
    else
        cd "${PROJECTS_DIR}/dotfiles"
        git pull
        log_warn "Dotfiles already configured... Pulled the latest changes" ""
    fi
}

configure_session() {
    mkdir -p "$XDG_CONFIG_HOME/zsh"
    touch "$XDG_CONFIG_HOME/zsh/.zprofile"

    ZPROFILE="$XDG_CONFIG_HOME/zsh/.zprofile"

    if [[ $USE_WAYLAND == "y" ]]; then
        log_info "[Configuring]:" "Sway"
        if ! grep -q "exec sway" "$ZPROFILE"; then
            cat << 'EOF' >> "$ZPROFILE"
# Auto-launch Sway on TTY1
if [[ -z $DISPLAY && "$(tty)" == "/dev/tty1" ]]; then
  exec sway
fi
EOF
            log_info "[Configured]:" "Sway set to auto-start on TTY1 login"
        fi
    else
        log_info "[Configuring]:" "i3"
        if ! grep -q "exec startx" "$ZPROFILE"; then
            cat << 'EOF' >> "$ZPROFILE"
# Auto-launch i3 via startx on TTY1
if [[ -z $DISPLAY && "$(tty)" == "/dev/tty1" ]]; then
  exec startx
fi
EOF
            log_info "[Contifured]:" "i3 set to auto-start on TTY1 login" ""
        fi
    fi
}

configure_zsh() {
    TARGET_SHELL="/usr/bin/zsh"
    if [[ $SHELL != "$TARGET_SHELL" ]]; then
        log_info "[Configuring]:" "Changing Default Shell to Zsh"
        if grep -q "^$TARGET_SHELL$" /etc/shells; then
            sudo chsh -s "$TARGET_SHELL" "$USER"
            log_info "✓ Default shell changed to Zsh for $USER" ""
        else
            log_error "[Error]:" "Zsh not found in /etc/shells. Skipping shell change."
        fi
    fi

    if ! grep -q "ZDOTDIR" /etc/zshenv 2> /dev/null; then
        log_info "[Configuring]:"  "Zsh Environment"
        mkdir -p "$XDG_STATE_HOME/zsh"
        touch "$XDG_STATE_HOME/zsh/zsh_history"

        echo "export ZDOTDIR=\$HOME/.config/zsh" | sudo tee -a /etc/zshenv > /dev/null

        # Clone plugins cleanly
        declare -A plugins=(
               ["zsh-vi-mode"]="https://github.com/jeffreytse/zsh-vi-mode.git"
               ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
               ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
               ["fzf-tab"]="https://github.com/Aloxaf/fzf-tab.git"
        )

        for plugin in "${!plugins[@]}"; do
            dest="$XDG_DATA_HOME/zsh/plugins/$plugin"
            if [[ ! -d "$dest" ]]; then
                git clone "${plugins[$plugin]}" "$dest" 2> /dev/null || true
            fi
        done
        log_info "✓ Zsh configured and plugins installed" ""
    fi
}

configura_nerdfont() {
    if [[ ! -d "/usr/share/fonts/jetbrains-mono" ]]; then
        log_info "[Installing]:" "JetBrains Mono Nerd Font"
        sudo mkdir -p /usr/share/fonts/jetbrains-mono

        # Download and unzip directly using absolute targeting paths
        sudo curl -fLo "/usr/share/fonts/jetbrains-mono/JetBrainsMono.zip" \
            "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"

        sudo unzip -o "/usr/share/fonts/jetbrains-mono/JetBrainsMono.zip" -d /usr/share/fonts/jetbrains-mono/
        sudo rm "/usr/share/fonts/jetbrains-mono/JetBrainsMono.zip"
        sudo fc-cache -fv
        log_info "✓ JetBrains Mono Nerd Font installed" ""
    fi
}

configure_nvm() {
    # Attempt source load
    [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"

    if ! command -v nvm &> /dev/null; then
        log_info "[Installing]:" "NVM and Node"
        mkdir -p "$XDG_DATA_HOME/nvm"
        curl -q -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash

        # Reload NVM explicitly
        [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"

        set +u
        nvm install --lts
        nvm alias default 'lts/*'
        set -u
        log_info "✓ NVM and Node LTS installed" ""
    fi

    log_info "[Installing]:" "Language Servers..."

    NODE_BIN_DIR=$(find "$NVM_DIR/versions/node" -maxdepth 2 -type d -name "bin" 2>/dev/null | head -n 1)

    if [[ -z $NODE_BIN_DIR || ! -f "$NODE_BIN_DIR/npm" ]]; then
        log_error "[Error]:" "Could not locate local NVM npm binary."
        exit 1
    fi

    ORIGINAL_PATH="$PATH"
    export PATH="$NODE_BIN_DIR:$PATH"

    servers=("bash-language-server" "stylelint-lsp" "typescript-language-server" "vscode-langservers-extracted")
    for server in "${servers[@]}"; do
        if ! npm list -g "$server" &> /dev/null; then
            npm install -g "$server"
            log_info "✓ $server installed" ""
        else
            log_warn "✓ $server is already installed" ""
        fi
    done

    export PATH="$ORIGINAL_PATH"
}

configure_git() {
    if [[ ! -d "$HOME/.ssh" ]]; then
        log_info "[Configuring]:" "Git & SSH Keys"
        mkdir -p "$XDG_CONFIG_HOME/git"
        git config --global user.name "$USER"
        git config --global user.email "$GITHUB_EMAIL"
        ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f "$HOME/.ssh/id_ed25519" -N "" || true

        log_info "✓" "Github configured successfully"
        log_warn "[IMPORTANT]:" "GitHub authentication still requires manual setup:"
        log_warn "  1." "Run: gh auth login"
        log_warn "  2." "Run: gh ssh-key add $HOME/.ssh/id_ed25519.pub --type signing"
        log_warn "  3." "Test: ssh -T git@github.com"
    fi
}

configure_hardware_and_daemons() {
log_info "[Configuring]:" "Hardware & Daemons..."
if command -v brightnessctl &> /dev/null; then
    sudo usermod -aG video "$USER"
fi

if ! sudo systemctl is-active --quiet power-profiles-daemon; then
    sudo systemctl enable --now power-profiles-daemon
fi
}

download_assets() {
    # Download Wallpaper
    mkdir -p "$HOME/Pictures"
    if [[ ! -f "$HOME/Pictures/wallpaper.jpg" ]]; then
        curl -L -o "$HOME/Pictures/wallpaper.jpg" "https://unsplash.com/photos/u27Rrbs9Dwc/download?force=true&w=1920" || echo "Warning: Wallpaper failed"
        log_info "[Dowloaded]:" "Wallpapper to $HOME/Pictures/wallpaper.jpg"
    else
        log_warn "[Skipping]:" "Wallpapper... $HOME/Pictures/wallpaper.jpg detected"
    fi

    # Download Screensaver
    if [[ ! -f "$HOME/Pictures/screensaver.png" ]]; then
        curl -L -o "$HOME/Pictures/screensaver.png" "https://images2.alphacoders.com/109/1098024.png" || echo "Warning: Screensaver failed"
        log_info "[Dowloaded]:" "Screensaver to $HOME/Pictures/wallpaper.jpg"
    else
        log_warn "[Skipping]:" "Screensaver... $HOME/Pictures/screensaver.png detected"
    fi
}

# Function that detects display environment
detect_display_enviroment() {
    if command -v i3 > /dev/null 2>&1 && ! command -v sway > /dev/null 2>&1; then
        USE_WAYLAND="n"
    elif command -v sway > /dev/null 2>&1 && ! command -v i3 > /dev/null 2>&1; then
        USE_WAYLAND="y"
    else
        while true; do
            read -r -p "Do you want to use Wayland with Sway? \(if no, use X11 with i3\) \(y/n\): " temp_input
            case "-$temp_input" in
                -[Yy]*)
                    USE_WAYLAND="y"
                    break
                ;;
                -[Nn]*)
                    USE_WAYLAND="n"
                    break
                ;;
                *) echo "Please answer y or n." ;;
            esac
        done
    fi
}


main() {
    detect_display_enviroment
    update_system
    configure_dotfiles
    configure_session
    configure_zsh
    configura_nerdfont
    configure_nvm
    configure_git
    configure_hardware_and_daemons
    download_assets

    log_info "✓ Setup log saved to: $LOG_FILE" ""
    log_info "✓ Installation Complete" ""
    log_warn "Next steps:" ""
    log_warn "  1. Manually complete GitHub authentication (see instructions above)" ""
    log_warn "  2. Reboot or log out, then log into TTY1 to auto-launch Sway/i3." ""
}

main
