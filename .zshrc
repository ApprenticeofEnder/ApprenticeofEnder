# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="geometry"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  fast-syntax-highlighting
  zsh-autocomplete
)

source $ZSH/oh-my-zsh.sh


# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vi'
else
  export EDITOR='nvim'
fi

alias cat=bat
alias yy=yazi
alias lg=lazygit

. "$HOME/.cargo/env"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

eval "$(uv generate-shell-completion zsh)"

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/home/ender/go/bin

eval "$(op completion zsh)"; compdef _op op

# Created by `pipx` on 2024-01-30 01:03:46
export PATH="$PATH:/home/ender/.local/bin"
# eval "$(register-python-argcomplete pipx)"

# opencode
export PATH=/home/ender/.opencode/bin:$PATH

eval "$(direnv hook zsh)"
