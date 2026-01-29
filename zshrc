# Where and how much
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

# Persistence & sharing
setopt appendhistory
setopt incappendhistory
setopt sharehistory

# Timestamps (optional)
setopt EXTENDED_HISTORY
HIST_STAMPS="%Y-%m-%d"

# Deduping
HISTDUP=erase
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups
setopt hist_ignore_space      
setopt hist_reduce_blanks
setopt hist_expire_dups_first

autoload -U compinit
compinit -C

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' completer _complete _correct _approximate
zstyle ':completion:*' rehash true

setopt extended_glob
setopt globdots
setopt numeric_globsort

# --- Minimal Git segment: branch + " *" when dirty; no "git" word ---
setopt prompt_subst

git_branch() {
  # Only show when inside a Git work tree
  git rev-parse --is-inside-work-tree &>/dev/null || return

  # Branch (or tag or short SHA fallback)
  local ref dirty
  ref=$(
    git symbolic-ref --quiet --short HEAD 2>/dev/null || \
    git describe --tags --exact-match 2>/dev/null || \
    git rev-parse --short HEAD 2>/dev/null
  )

  # Dirty if there are changes (tracked OR untracked).
  # To ignore untracked files, change to: git status --porcelain -uno
  if [[ -n $(GIT_OPTIONAL_LOCKS=0 git status --porcelain 2>/dev/null) ]]; then
    dirty=" %F{196}*"
  else
    dirty=""
  fi

  # Output: branch + optional star; no prefixes
  print -nr -- "%F{196}${ref}%f${dirty}"
}

# --- No right prompt ---
unset RPROMPT

PROMPT=$'\n%F{44}%n%f%F{38}:%1~/%f $(git_branch)\n%F{44}%% %f'

export LANG=en_US.UTF-8

alias ls='ls -G'
alias ll='ls -l'
alias lrt='ll -rt'
alias reload='source ~/.zshrc'
# --- Git ---
# Remove every local branch not existing on remote
git_remove_dead_branches()
{
  git fetch -p && for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do git branch -D $branch; done
}
alias gc='git checkout'
alias gcb='git checkout -b'
