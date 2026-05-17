# Setup fzf
# ---------
if [[ ! "$PATH" == */home/ben/.local/share/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/ben/.local/share/fzf/bin"
fi

source <(fzf --zsh)
