# Enable command auto-correction
setopt CORRECT

# Set history options
HISTSIZE=1000
SAVEHIST=2000
HISTCONTROL=ignoreboth

# Enable completion
autoload -Uz compinit
compinit

export CLICOLOR=1

# Aliases
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias ll='ls -lF'
alias lrt='ll -rt'
alias lg='ll | grep -i $1'
alias reload='source ~/.zshrc'

PROMPT='%n@%m %1~ %# '

# Remove every local branch not existing on remote
git_remove_dead_branches() {
  git fetch -p && for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do git branch -D $branch; done
}

# Remove tag on remote and locally
git_remove_tag() {
  git push origin :refs/tags/$1
  git tag --delete $1
}

# Override branch with state from another branch
git_override_current_branch() {
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
  source ~/.local-stuff
fi
