# set prompt to current directory in bold with colors
PS1="%F{#98971a}➜  %f %B%F{#83a598}%1~%f%b %F{#a89984}>%f "

# initialize and start the zsh completion system
autoload -U compinit && compinit

# Use vi keybindings even if our EDITOR is set to vi
bindkey -v

########### options ###########
#
### history ###
#
# Keep 10000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTFILE="$XDG_STATE_HOME/zsh/zsh_history"
HISTDUP=erase

# append to history file instead of replacing when using multiple zsh sessions
setopt APPEND_HISTORY
# append the command without waiting for shell exit
setopt INC_APPEND_HISTORY
# enable to see previous commands that has been entered using different terminals
setopt SHARE_HISTORY
# don't display duplicate history entries when searching through history
setopt HIST_FIND_NO_DUPS
# when a duplicate command is added, removes the old command
setopt HIST_IGNORE_ALL_DUPS
# ignore duplicate commands when they are executed back-to-back
setopt HIST_IGNORE_DUPS
# ignore commands that start with a space character, for privacy concerns0
setopt HIST_IGNORE_SPACE
# prevent saving duplicate commands to the history file
setopt HIST_SAVE_NO_DUPS

########### aliases ###########
#
# colors to differentiate the type of file
alias ls="ls --color=auto"

########### configure fzf-tab ###########
#
# use 'FZF_DEFAULT_OPTS' to style fzf-tab widget
zstyle ':fzf-tab:*' use-fzf-default-opts yes

########### configure zsh-vi-mode ###########
#
# edit current command line using neovim
ZVM_VI_EDITOR=nvim
# trigger history search in insert mode
ZVM_INIT_MODE=sourcing

# This loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# This loads nvm completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

########### plugins ###########
#
source $XDG_DATA_HOME/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh
source $XDG_DATA_HOME/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $XDG_DATA_HOME/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
source $XDG_DATA_HOME/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

########### configure fzf ###########
# Note: zsh-vi-mode must be sourced before 'zvm_bindkey' can be used
#
# use Ctrl-e to trigger fzf cd widget 
bindkey '^e' fzf-cd-widget
# when in normal mode, trigger fzf cd widget
# fix: conflicts with normal mode's default CTRL+e keybinding
zvm_bindkey vicmd '^e' fzf-cd-widget
# in insert mode, search backward through history for similar commands.
zvm_bindkey viins '^p' history-search-backward
# in insert mode, search forward through history for similar commands. 
zvm_bindkey viins '^n' history-search-forward
