#!/usr/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

RED="\e[1;31m"
GREEN="\e[1;32m"
BLUE="\e[1;34m"
YELLOW="\e[1;33m"
RESET="\e[0m"

# Script take one argument
# $2, $3... are ignored
if [ $# -eq 0 ]; then
    echo -e "${RED}[Error]:${RESET} usage: ./$0 <github_email>"
    exit 1
fi

GITHUB_EMAIL="$1"
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

LOG_FILE="/tmp/bootstrap_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

# Function to output successful message
# @1 blue text
# @2 text
log_info() {
    echo -e "${BLUE}$1${RESET} $2"
}

# Function to output successful message
# @1 green text
# @2 text
log_success() {
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

            local full_backup_path
            full_backup_path="${backup_directory}/${destination##*/}_$(date +%Y%m%d_%H%M%S)"

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

detect_distro() {
    local distro
    distro=$(grep "^ID=" /etc/os-release | cut -d= -f2)

    case "$distro" in
        "fedora" | "arch")
            log_info "[Detected]:" "${distro}"
            DISTRO="$distro"
         ;;
        *)
            log_error "[Error]:" "Unsupported distro detected: ${distro}"
            exit 1
        ;;
    esac
}

# Function to get the user to choose Sway or i3
prompt_user() {
        while true; do
            read -r -p "Do you want to use Wayland with Sway? (if no, use X11 with i3) (y/n): " temp_input
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
}

# Function that detects display environment
detect_display_enviroment() {
    if [[ "$XDG_SESSION_TYPE" == "wayland" &&
         ("$DISTRO" == "fedora" || "$DISTRO" == "arch") ]]; then
        log_info "[Detected]:" "wayland session"
        USE_WAYLAND="y"
    elif [[ "$XDG_SESSION_TYPE" == "x11" &&
           ("$DISTRO" == "fedora" || "$DISTRO" == "arch") ]]; then
        log_info "[Detected]:" "x11 session"
        USE_WAYLAND="n"
    elif [[ "$XDG_SESSION_TYPE" == "tty" && "$DISTRO" == "arch" ]]; then
        prompt_user
    elif [[ "$XDG_SESSION_TYPE" == "tty" && "$DISTRO" == "fedora" ]]; then
        if command -v sway > /dev/null 2>&1 && ! command -v i3 > /dev/null 2>&1; then
            # Fedora Sway Spin
            USE_WAYLAND="y"
        elif command -v i3 > /dev/null 2>&1 && ! command -v sway > /dev/null 2>&1; then
            # Fedora i3 Spin
            USE_WAYLAND="n"
        else
            # Fedora Workstation
            prompt_user
        fi
    else
        log_error "[Error]: ${XDG_SESSION_TYPE} session" ""
        log_error "     It looks like you've already executed the script." ""
        log_error "     Cannot run the script in a tty environment AFTER a successfully execution" ""
        log_error "     To successfully execute the script again, execute in a wayland/x11 session" ""
        exit 1
    fi
}

# Function to install any upgrade and core tools
update_system() {
    log_info "[Bootstrap]:" "Updating the system"

    local package_manager

    if [[ "$DISTRO" == "fedora" ]]; then
        sudo dnf upgrade --refresh -y
        package_manager="sudo dnf install -y"
    else
        sudo pacman -Syu --noconfirm
        package_manager="sudo pacman -S --needed --noconfirm"
    fi

    if [[ "$USE_WAYLAND" == 'y' ]]; then
        log_info "[Installing]:" "Sway suite"
        $package_manager sway swaybg swaylock waybar wofi wl-clipboard
    else
        log_info "[Installing]:" "i3 suite"
        $package_manager i3 polybar i3lock rofi feh xclip
    fi

    if [[ "$DISTRO" == "fedora" && "$USE_WAYLAND" == "n" ]]; then
        $package_manager xorg-x11-server-Xorg xorg-x11-xinit
    elif [[ "$DISTRO" == "arch" && "$USE_WAYLAND" == "n" ]]; then
        $package_manager xorg-server xorg-xinit
    fi

    log_info "[Installing]:" "Applications"

    if [[ "$DISTRO" == "fedora" ]]; then
        $package_manager @development-tools git unzip \
            zsh bat fd-find ripgrep tree gh ranger gcc-c++ \
            brightnessctl alacritty neovim btop fzf \
            dunst shfmt shellcheck terminus-fonts-console
        # Remove tuned in favor of power-profiles-daemon
        $package_manager --allowerasing power-profiles-daemon python-gobject
    else
        $package_manager \
            base-devel git unzip curl pipewire pipewire-pulse wireplumber \
            zsh bat fd ripgrep tree github-cli ranger brightnessctl \
            alacritty neovim btop fzf ttf-jetbrains-mono-nerd openssh \
            firefox dunst power-profiles-daemon libnotify shfmt shellcheck terminus-font zram-generator
    fi
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

            link_directory "$directory"
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

        log_success "Dotfiles successfully configured" ""
    else
        cd "${PROJECTS_DIR}/dotfiles"
        git pull
        log_warn "Dotfiles already configured... Pulled the latest changes" ""
    fi
}

configure_session() {
    mkdir -p "$XDG_CONFIG_HOME/zsh"
    touch "$XDG_CONFIG_HOME/zsh/.zprofile"

    local zprofile_path="$XDG_CONFIG_HOME/zsh/.zprofile"

    if [[ "$USE_WAYLAND" == "y" ]]; then
        log_info "[Configuring]:" "Sway"
        if ! grep -q "exec sway" "$zprofile_path"; then
            cat << 'EOF' >> "$zprofile_path"
# Auto-launch Sway on login
if [[ -z "$DISPLAY" && "$(tty)" == "/dev/tty1" ]]; then
  exec sway
fi
EOF
            log_success "[Configured]:" "Sway"
        fi
    else
        log_info "[Configuring]:" "i3"

        # Manually have to change the XDG_SESSION_TYPE enviroment variable
        echo -e "export XDG_SESSION_TYPE=x11\nexport XDG_CURRENT_DESKTOP=i3\n\nexec i3" > "${HOME}/.xinitrc"

        if [[ "$DISTRO" == "arch" ]]; then
            # Ensure the profile file exists
            mkdir -p "$XDG_CONFIG_HOME/zsh"
            touch "$XDG_CONFIG_HOME/zsh/.zprofile"
        fi

        if ! grep -q "exec startx" "$zprofile_path"; then
            cat << 'EOF' >> "$zprofile_path"
# Auto-launch i3 via startx on login
if [[ -z "$DISPLAY" && "$(tty)" == "/dev/tty1" ]]; then
  exec startx
fi
EOF
            log_success "[Configured]:" "i3"
        fi
    fi
}

configure_zsh() {
    local target_shell="/usr/bin/zsh"
    local zsh_system_directory

    if [[ "$DISTRO" == "fedora" ]]; then
        zsh_system_directory="/etc/zshenv"
    else
        zsh_system_directory="/etc/zsh/zshenv"
    fi

    if [[ $SHELL != "$target_shell" ]]; then
        log_info "[Configuring]:" "Changing Default Shell to Zsh"
        if grep -q "^$target_shell$" /etc/shells; then
            sudo chsh -s "$target_shell" "$USER"
            log_success "Default shell changed to Zsh for $USER" ""
        else
            log_error "[Error]:" "Zsh not found in /etc/shells. Skipping shell change."
        fi
    fi

    if ! grep -q "ZDOTDIR" $zsh_system_directory  2> /dev/null; then
        log_info "[Configuring]:"  "Zsh Environment"
        mkdir -p "$XDG_STATE_HOME/zsh"
        touch "$XDG_STATE_HOME/zsh/zsh_history"

        echo "export ZDOTDIR=\$HOME/.config/zsh" | sudo tee -a $zsh_system_directory > /dev/null

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
                log_info "[Installed]:" "${plugins[$plugin]}"
            fi
        done
        log_success "[Configured]" "Zsh"
    fi
}

configure_nerdfont() {
    # Arch installed via package manager
    [[ "$DISTRO" != "fedora" ]] && return 0

    if [[ ! -d "/usr/share/fonts/jetbrains-mono" ]]; then
        log_info "[Installing]:" "JetBrains Mono Nerd Font"
        sudo mkdir -p /usr/share/fonts/jetbrains-mono

        # Download and unzip directly using absolute targeting paths
        sudo curl -fLo "/usr/share/fonts/jetbrains-mono/JetBrainsMono.zip" \
            "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"

        sudo unzip -o "/usr/share/fonts/jetbrains-mono/JetBrainsMono.zip" -d /usr/share/fonts/jetbrains-mono/
        sudo rm "/usr/share/fonts/jetbrains-mono/JetBrainsMono.zip"
        sudo fc-cache -fv
        log_success "[Installed]:" "JetBrains Mono Nerd Font"
    else
        log_warn "[Skipping]:" "JetBrains Mono Nerd Font detected"
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
        log_success "NVM and Node LTS installed" ""
    fi

    log_info "[Installing]:" "Language Servers..."

    NODE_BIN_DIR=$(find "$NVM_DIR/versions/node" -maxdepth 2 -type d -name "bin" 2> /dev/null | head -n 1)

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
            log_success "[Installed]:" "$server"
        else
            log_warn "[Skipping]:" "$server is already installed"
        fi
    done

    export PATH="$ORIGINAL_PATH"
}

configure_swap() {
    # Fedora comes pre-installed with zram0
    [[ "$DISTRO" != "arch" ]] && return 0

    # Make sure unit isn't already running
    if ! sudo systemctl is-active --quiet systemd-zram-setup@zram0.service; then
        log_info "[Contiguring]:" "Swap Memory"
        # fix: permission denied error:
        # Use sudo tee -a instead of >> redirection
            cat << 'EOF' | sudo tee -a "/etc/systemd/zram-generator.conf" > /dev/null
[zram0]
# Allocate zram size equal to total physical RAM
# Note: If you want it smaller, you can use zram-size = ram / 2 instead.
zram-size = ram

# Use zstd for the best balance of speed and high compression ratio
compression-algorithm = zstd
EOF
        sudo systemctl daemon-reload
        sudo systemctl start systemd-zram-setup@zram0.service

        log_success "[Configured]:" "Swap Memory with zram0"
        log_info "Run lsblk or zramctl to verify" ""
    else
        log_warn "[Skipping]:" "Swap Memory is already configured"
    fi
}

configure_hardware_and_daemons() {
    log_info "[Configuring]:" "Hardware & Daemons..."

    if ! command -v brightnessctl &> /dev/null; then
        sudo usermod -aG video "$USER"
        log_success "[Configured]:" "brightnessctl"
    else
        log_warn "[Skipping]:" "brightnessctl already configured" ""
    fi

    if ! sudo systemctl is-active --quiet power-profiles-daemon; then
        sudo systemctl enable --now power-profiles-daemon
        log_success "[Configured]:" "power-profiles-daemon"
    else
        log_warn "[Skipping]:" "power-profiles-daemon already configured" ""
    fi

    if [[ "$DISTRO" == "arch" && ! -d "${XDG_CONFIG_HOME}/systemd" ]]; then
        systemctl --user enable --now pipewire pipewire-pulse wireplumber
        log_success "[Configured]:" "audio daemons"
    else
        log_warn "[Skipping]:" "audio daemons have already been configured" ""
    fi

    local vconsole_config="/etc/vconsole.conf"

    # Remove display manager on fedora and setup TTY1 login with bigger font
    if [[ "$DISTRO" == "fedora" ]] && [[ "$(systemctl is-active display-manager)" == "active" ]]; then
        sudo systemctl disable display-manager
        sudo systemctl set-default multi-user.target

        if ! grep -q "^FONT=\"ter-132b\"" "$vconsole_config"; then
            # Check for a FONT entry, if there is comment it out before
            # appending a the new font
            local vconsole_font
            vconsole_font=$(grep "^FONT=" "$vconsole_config")
            if [[ -n "$vconsole_font" ]]; then
                log_warn "Commenting out ${vconsole_font} before appending to ${vconsole_config}" ""
                # Modify /etc/vconsole.conf by commenting out the previous FONT
                sudo sed -i 's/\(^FONT=.*\)/#\1/' "$vconsole_config"
            fi

            # Configure the tty font
            echo -e "FONT=\"ter-132b\"" | sudo tee -a "$vconsole_config" > /dev/null
            # force Fedora to rebuild the boot image with the new font settings
            log_info "[Configuring]:" "The boot image... Rebuilding (this can take a few minutes)"
            sudo dracut -f --regenerate-all
            log_success "[Configured]:" "Boot image has been successfully rebuilt (reboot required)"
            log_success "[Configured]:" "tty login"
        fi

    # Setup TTY1 login with bigger font
    elif [[ "$DISTRO" == "arch" ]] && ! grep -q "FONT=ter-" "$vconsole_config"; then
        log_info "[Configuring]:" "Rebuilding the boot image..."

        local mkinicpid_config="/etc/mkinitcpio.conf"

        echo -e "FONT=ter-132b" | sudo tee -a "$vconsole_config" > /dev/null

        # 1. Check if vconsole is already in the HOOKS array
        if grep -qE '^HOOKS=.*\<vconsole\>' "$mkinicpid_config"; then
            log_warn "[Skipping]:" "vconsole hook is already present in $mkinicpid_config."
        else
            log_info "[Configuring]" "Adding vconsole hook to $mkinicpid_config..."

            # 2. Inject 'vconsole' right before 'block' or 'filesystems'
            # This ensures proper ordering without breaking existing setups.
            if grep -q "block" "$mkinicpid_config"; then
                sed -i 's/\<block\>/vconsole block/' "$mkinicpid_config"
            elif grep -q "filesystems" "$mkinicpid_config"; then
                sed -i 's/\<filesystems\>/vconsole filesystems/' "$mkinicpid_config"
            else
                # Fallback: Just append it to the end of the array if 'block'/'filesystems' aren't found
                sed -i 's/\(^HOOKS=(.*\)\()$\)/\1 vconsole\2/' "$mkinicpid_config"
            fi

            log_success "[Configured]:" "Successfully updated HOOKS."
        fi
        log_success "[Configured]:" "Boot image has been rebuilt(reboot required)"
    else
        log_warn "[Skipping]:" "tty login is already configured"
    fi
}

download_assets() {
    # Download Wallpaper
    mkdir -p "$HOME/Pictures"
    if [[ ! -f "$HOME/Pictures/wallpaper.jpg" ]]; then
        curl -L -o "$HOME/Pictures/wallpaper.jpg" "https://unsplash.com/photos/u27Rrbs9Dwc/download?force=true&w=1920" || echo "Warning: Wallpaper failed"
        log_success "[Dowloaded]:" "Wallpapper to $HOME/Pictures/wallpaper.jpg"
    else
        log_warn "[Skipping]:" "Wallpapper... $HOME/Pictures/wallpaper.jpg detected"
    fi

    # Download Screensaver
    if [[ ! -f "$HOME/Pictures/screensaver.png" ]]; then
        curl -L -o "$HOME/Pictures/screensaver.png" "https://images2.alphacoders.com/109/1098024.png" || echo "Warning: Screensaver failed"
        log_success "[Dowloaded]:" "Screensaver to $HOME/Pictures/wallpaper.jpg"
    else
        log_warn "[Skipping]:" "Screensaver... $HOME/Pictures/screensaver.png detected"
    fi
}

configure_git() {
    if [[ ! -d "$HOME/.ssh" ]]; then
        log_info "[Configuring]:" "Git & SSH Keys"

        # Make sure paths exists
        mkdir -p "$XDG_CONFIG_HOME/git"
        mkdir -p "$$HOME/.ssh"

        # Make sure config file exists
        touch "$XDG_CONFIG_HOME/git/config"

        git config --global user.name "$USER"
        git config --global user.email "$GITHUB_EMAIL"

        ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f "$HOME/.ssh/id_ed25519" -N "" || true

        log_success "[Configured]:" "Github successfully"
        log_warn "[IMPORTANT]:" "GitHub authentication still requires manual setup:"
        log_warn "  1." "Run: gh auth login"
        log_warn "  2." "Run: gh ssh-key add $HOME/.ssh/id_ed25519.pub --type signing"
        log_warn "  3." "Test: ssh -T git@github.com"
    fi
}

main() {
    detect_distro
    detect_display_enviroment
    update_system
    configure_dotfiles
    configure_session
    configure_zsh
    configure_nerdfont
    configure_nvm
    configure_hardware_and_daemons
    download_assets
    configure_swap
    configure_git

    log_success "=============================================" ""
    log_success "=========== Installation Complete ===========" ""
    log_success "=============================================" ""
    log_info "Setup log saved to: $LOG_FILE" ""

    if [[ "$USE_WAYLAND" == "y" && "$DISTRO" == "arch"  ]]; then
        log_warn "NOTE: if running on a VirtualBox machine" ""
        log_warn "   Add the following to the top of $XDG_CONFIG_HOME/zsh/.zprofile" ""
        log_warn "      export WLR_RENDERER=pixman" ""
        log_warn "      export WLR_NO_HARDWARE_CURSORS=1" ""
    fi
    log_warn "Next steps:" ""
    log_warn "  1. Manually complete GitHub authentication (see instructions above)" ""
    log_warn "  2. Reboot or log out to auto-launch Sway/i3." ""
}

main
