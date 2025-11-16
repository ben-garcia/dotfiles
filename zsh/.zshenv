export EDITOR="nvim"

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# vars necessary to configure 3rd party apps to the xdg specification
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GOPATH="$XDG_DATA_HOME/go"
export LESSHISTFILE="${XDG_STATE_HOME}/lesshst"
export NVM_DIR="$XDG_DATA_HOME/nvm"
export PSQL_HISTORY="$XDG_STATE_HOME/psql_history"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export REDISCLI_HISTFILE="$XDG_STATE_HOME/redis"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
# export ZDOTDIR="$XDG_CONFIG_HOME/zsh"  setup in /etc/zsh/zshenv

# this line to set the PATH to the default locations
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
# include user defined binaries
# NOTE: instead of adding installed binaries to $PATH manually for every program,
#       add all binaries to .local/bin to clean up $PATH
export PATH="$HOME/.local/bin:$PATH"
# add cargo bin directory to the path
export PATH="$XDG_DATA_HOME/cargo/bin:$PATH"
# add fzf bin directory to the path
export PATH="$XDG_DATA_HOME/fzf/bin:$PATH"

# set bat command syntax highlighting theme to 'gruvbox-dark'
export BAT_THEME="gruvbox-dark"

# set zsh-vi-mode background color when in visual mode
export ZVM_VI_HIGHLIGHT_BACKGROUND=#83A598

# fzf
# use fd to generate the list
export FZF_DEFAULT_COMMAND="fd"
# fzf with gruvbox dark colors
export FZF_DEFAULT_OPTS="--style=full --height=40% --layout=reverse 
  --color fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
  --color info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54
  "
# add preview for CTRL-T
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {}'"
# add preview for ALT-C
export FZF_ALT_C_OPTS="--walker-skip .git,node_modules,target --preview 'tree -C {}'"
