# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# Get GIT Branch
parse_git_dirty()
{
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working tree clean" ]] && echo "*"
}

parse_git_branch()
{
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/(\1$(parse_git_dirty))/"
}

if [ "$color_prompt" = yes ] && [ "git rev-parse --is-inside-work-tree" ]; then
    PS1="${debian_chroot:+($debian_chroot)}\[\033[1;31m\]\u@\h\[\033[00m\]: \[\033[1;30m\]\w\n\[\033[1;30m\]\$(date +%H:%M)\[\033[1;34m\] \$(parse_git_branch)\[\033[0;37m\]$ "
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\h: \W\a\]$PS1"
    ;;
*)
    ;;
esac

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Alias
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias ll='ls -lF'
alias lrt='ll -rt'
alias lg='ll | grep -i $1'
alias reload='source ~/.bashrc'

# Remove every local branch not existing on remote
git_remove_dead_branches()
{
  git fetch -p && for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do git branch -D $branch; done
}
# Remove tag on remote and locally
git_remove_tag()
{
  git push origin :refs/tags/$1
  git tag --delete $1
}

# Override branch with state from another branch
git_override_current_branch()
{
  if [ $# -ne 1 ]; then
    echo "Usage: override_current_branch <source_branch>"
    return 1
  fi

  local source_branch="$1"
  local current_branch=$(git symbolic-ref --short HEAD)

  # Check if the source branch exists
  if ! git show-ref --verify --quiet "refs/heads/$source_branch"; then
      echo "Source branch '$source_branch' does not exist."
      return 1
  fi

  # Reset the current branch to the commit from the source branch
  git reset --hard "$source_branch"

  # Push the changes to the remote repository
  git push --force origin "$current_branch"
}

# Tag annotated and push to remote
git_tag() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: git_tag <tag_name> <tag_message>"
        return 1
    fi

    tag_name="$1"
    tag_message="$2"

    git tag -a "$tag_name" -m "$tag_message" && git push origin "$tag_name"
}

# Source locally needed alias and stuff
if [ -f ~/.local-stuff ]; then
  . ~/.local-stuff
fi
