# Turn off all beeps
unsetopt BEEP

HOMEBREW_NO_AUTO_UPDATE=1

# Load colors so we can access $fg and more.
autoload -U colors && colors

# setting `TERM = xterm-256color` in alacritty sometimes isn't being read, force
export TERM="xterm-256color"

plugins=(git)
ZSH_THEME="robbyrussell"
DISABLE_AUTO_UPDATE="true" # disable oh-my-zsh auto-update
source $XDG_CONFIG_HOME/zsh/ohmyzsh/oh-my-zsh.sh
unsetopt autocd


case $(uname) in
"Linux")
    eval $(env TERM=xterm-256color dircolors)
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

    # Bash's readline (.inputrc) functionality
    # Start typing + [Up-Arrow] - fuzzy find history forward
    if [[ -n "${terminfo[kcuu1]}" ]]; then
      autoload -U up-line-or-beginning-search
      zle -N up-line-or-beginning-search
      bindkey -M emacs "${terminfo[kcuu1]}" up-line-or-beginning-search
      bindkey -M viins "${terminfo[kcuu1]}" up-line-or-beginning-search
      bindkey -M vicmd "${terminfo[kcuu1]}" up-line-or-beginning-search
    fi

    # Start typing + [Down-Arrow] - fuzzy find history backward
    if [[ -n "${terminfo[kcud1]}" ]]; then
      autoload -U down-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey -M emacs "${terminfo[kcud1]}" down-line-or-beginning-search
      bindkey -M viins "${terminfo[kcud1]}" down-line-or-beginning-search
      bindkey -M vicmd "${terminfo[kcud1]}" down-line-or-beginning-search
    fi

	;;
"Darwin")
    # homebrew
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"

    # # dircolors is a GNU utility that's not on macOS by default. With this not
    # # being used on macOS it means zsh's complete menu won't have colors.
    # command -v gdircolors > /dev/null 2>&1 && eval "$(gdircolors -b)"
    # https://geoff.greer.fm/lscolors/
    export CLICOLOR=1
    export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd # Linux default colors

    # terminfo (above) doesn't work for macOS Monterey
    autoload -U up-line-or-beginning-search
    zle -N up-line-or-beginning-search
    bindkey -M emacs "^[[A" up-line-or-beginning-search
    bindkey -M viins "^[[A" up-line-or-beginning-search
    bindkey -M vicmd "^[[A" up-line-or-beginning-search

    autoload -U down-line-or-beginning-search
    zle -N down-line-or-beginning-search
    bindkey -M emacs "^[[B" down-line-or-beginning-search
    bindkey -M viins "^[[B" down-line-or-beginning-search
    bindkey -M vicmd "^[[B" down-line-or-beginning-search

    # gnu-tar
    export PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"
	;;
esac

# Disable CTRL-s from freezing your terminal's output.
stty stop undef

# see https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/key-bindings.zsh

# [Ctrl-RightArrow] - move forward one word
bindkey -M emacs '^[^[[C' forward-word
bindkey -M viins '^[^[[C' forward-word
bindkey -M vicmd '^[^[[C' forward-word
# [Ctrl-LeftArrow] - move backward one word
bindkey -M emacs '^[^[[D' backward-word
bindkey -M viins '^[^[[D' backward-word
bindkey -M vicmd '^[^[[D' backward-word

# enable emacs
bindkey -e
# enable vim
# bindkey -v

# history settings
export HISTSIZE=100000 # maximum events for internal history
export SAVEHIST=$HISTSIZE # maximum events in history file
export HISTFILE="$HOME/.zsh_history"
setopt EXTENDED_HISTORY # Write the history file in the ':start:elapsed;command' format.
setopt SHARE_HISTORY # Share history between all sessions.
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS # Do not display a previously found event.
setopt HIST_IGNORE_SPACE # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS # Do not write a duplicate event to the history file.
setopt HIST_VERIFY # Do not execute immediately upon history expansion.
setopt HIST_REDUCE_BLANKS    # Remove unnecessary blank lines.
setopt INTERACTIVE_COMMENTS # Enable comments when working in an interactive shell.
setopt GLOB_DOTS # list all hidden files
setopt PROMPT_SUBST # ??



# zsh
source "$ZDOTDIR/zsh-functions"

eval "$(fnm env)"
# FUCK NVM, use fnm
# # node version manager
# export NVM_DIR="$HOME/.nvm"
# export NVM_COMPLETION=false #significant slows zsh
# export NVM_LAZY_LOAD=true
# # export PATH=$PATH:$(npm config --global get prefix)/bin
# [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
# [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
# [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

# plugins
zsh_add_plugin "Aloxaf/fzf-tab" # must be loaded FIRST!!! also unstable
zsh_add_plugin "zsh-users/zsh-autosuggestions"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242,underline,bold'
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)
ZSH_AUTOSUGGEST_MAX_BUFFER_SIZE=20
zsh_add_plugin "zdharma-continuum/fast-syntax-highlighting"
# zsh_add_plugin "lukechilds/zsh-nvm"
zsh_add_plugin "rupa/z"
zsh_add_plugin "sharkdp/fd"
FD_COMPLETION_DIR="$ZDOTDIR/plugins/fd/contrib/completion"
[ -d $FD_COMPLETION_DIR ] && fpath+=$FD_COMPLETION_DIR
zsh_add_plugin "conda-incubator/conda-zsh-completion"

# autocompletion
[ -d $ZDOTDIR/completions ] && fpath+="$ZDOTDIR/completions/"
autoload bashcompinit && bashcompinit
autoload -Uz compinit bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
# original zstyle setting before fixing speed
zstyle ':bracketed-paste-magic' active-widgets '.self-*'

# source: https://gist.github.com/magicdude4eva/2d4748f8ef3e6bf7b1591964c201c1ab
### Fix slowness of pastes with zsh-syntax-highlighting.zsh
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}
pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
### Fix slowness of pastes
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# git completions
zstyle ':completion:*:*:git:*' script $ZDOTDIR/plugins/git/contrib/completion/git-completion.bash
export GIT_COMPLETION_CHECKOUT_NO_GUESS=1

######################## fzf-tab settings ####################################
# trigger continuous completion, useful for completion long paths
# default value, but we use '/' in branch names a lot
# zstyle ':fzf-tab:*' continuous-trigger '/'
zstyle ':fzf-tab:*' continuous-trigger '\'
# show completion colors (like Bash's `set colored-completion-prefix on`)
zstyle ':completion:*' list-colors ${(@s.:.)LS_COLORS}
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort true

which pip &> /dev/null && eval "`pip completion --zsh`"
# case insensitive autocompletion
zstyle ':completion:*' matcher-list '' '+m:{a-zA-Z}={A-Za-z}' '+r:|[._-]=* r:|=*' '+l:|=* r:|=*'
# whether to show dirs ./ and ../
zstyle ':completion:*' special-dirs false
_comp_options+=(globdots)
compinit -i


# aliases
source $DOTFILES/.sh_aliases


# aliases ripped off Bash
# enable color support of ls and also add handy aliases
alias ls='ls --color=auto -hp'
alias dir='dir --color=auto -h'
alias vdir='vdir --color=auto -h'

alias grep='grep --color=auto --ignore-case'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
# some more ls aliases
alias ll='ls -alFh'
alias la='ls -Aph'
alias l='ls -CFph'


# fzf
export FZF_COMPLETION_TRIGGER='**'
export FZF_COMPLETION_OPTS='--multi --inline-info --border'
export FZF_DEFAULT_OPS='--multi --inline-info --border'
export FZF_DEFAULT_COMMAND="rg --files --hidden $(test -d .git && echo '-g !.git')"
export FZF_CTRL_T_COMMAND="fd --type file --follow --hidden --exclude .git --strip-cwd-prefix"
# export FZF_CTRL_T_COMMAND=""
# TODO disabling CTRL-T for now since i use tmux alot
# bindkey -r '^T'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# tldr
[ -f ~/bin/tldr ] && compctl -k "($( tldr 2>/dev/null --list))" tldr

# sumo
export SUMO_HOME="/usr/share/sumo"

# foundry
export PATH="$PATH:$HOME/.foundry/bin"

# diff-so-fancy
export EDITOR="$HOME/opt/nvim-macos-arm64/bin/nvim"
export GPG_TTY=$(tty)

# rust
[ -f ~/.cargo/env ] && source ~/.cargo/env

# CUDA and cuDNN
export PATH="/usr/local/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH"
export CUDA_ROOT="/usr/local/cuda"

# ros stuff
[ -d /opt/ros ] && ROS_VER=$(ls /opt/ros)
ROS_SETUP_FILE=/opt/ros/$ROS_VER/setup.zsh
[ ! -z $ROS_VER ] && [ -f $ROS_SETUP_FILE ] && source $ROS_SETUP_FILE

# git diff in terms of commits...
gdf() {
	echo 'Commits that exist in '$1' but not in '$2':'
	git log --graph --pretty=format:'%Cred%h%Creset %s' --abbrev-commit $2..$1
	echo '\n\nCommits that exist in '$2' but not in '$1':'
	git log --graph --pretty=format:'%Cred%h%Creset %s' --abbrev-commit $1..$2
}

curbranch() {
    git rev-parse --abbrev-ref HEAD
}

# lol
cb() {
    git rev-parse --abbrev-ref HEAD
}

export PATH="$(python3 -m site --user-base)/bin:$PATH"
export PATH="$PATH:/Users/evan/.config/.foundry/bin"

# # add homebrew bin for postgresql@15
use_pg16(){
    export PATH=$PATH:$HOMEBREW_PREFIX/opt/postgresql@16/bin
}
use_pg15(){
    export PATH=$PATH:$HOMEBREW_PREFIX/opt/postgresql@15/bin
}
# use_pg16

eval "$(direnv hook zsh)"
conda_remove() {
    for env in "$@"
    do
        conda env remove -n "$env"
    done
}

# OpenSSH agent on a stable socket (shared across shells/tmux)
export SSH_AUTH_SOCK="$HOME/.ssh/ssh-agent.sock"

# ssh-add -l exit codes: 0 keys loaded, 1 no keys, 2 no agent
ssh-add -l >/dev/null 2>&1
if [ $? -ge 2 ]; then
    rm -f "$SSH_AUTH_SOCK"
    ssh-agent -a "$SSH_AUTH_SOCK" >/dev/null
fi

# GPG for signing/encryption only (SSH is handled by OpenSSH agent)
gpgconf --launch gpg-agent >/dev/null 2>&1
gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1

# Use fz for frecency-based directory jumping with proper ranking
alias zf='fz'
# for a silent tmux sessionizer experience
# Define a custom to run tmux-sessionizer
tmux_sessionizer_widget() {
  zle -I # Clear the input line
  tmux-sessionizer
  zle reset-prompt # Reset the prompt
}
# Bind the custom widget to Ctrl+f
zle -N tmux_sessionizer_widget
tmux_windowizer_widget() {
  zle -I # Clear the input line
  tmux-windowizer
  zle reset-prompt # Reset the prompt
}
zle -N tmux_windowizer_widget

windowizer() {
    if [[ -n $TMUX ]]; then
        tmux-windowizer "$@"
    else
        local selected=$(~/.local/bin/windowizer "$@")
        [[ -n $selected ]] && cd "$selected"
    fi
}

windowizer_widget() {
    zle -I
    windowizer
    zle reset-prompt
}
zle -N windowizer_widget

#
# NOTE: use the widgets if you want cleaner outputs from previous terminals
# bindkey -s '^f' 'tmux-windowizer\n'
# bindkey -s '^f' 'tmux-sessionizer\n'
bindkey -s '^f' 'windowizer\n'

# Where should I put you?
# bindkey -s ^f "tmux-sessionizer\n"

# Function to parse the line and search for matching Host entries in ~/.ssh/config
parse_and_search_ssh_config() {
    local line="$@"
    local hostname=$(echo $line | sed -E 's#git@([^:]+):.*#\1#')

    # echo "Searching for matching Host entries in ~/.ssh/config for hostname: $hostname"

    # Create an array of SSH config objects
    local -a arr
    arr=("${(@f)$(cat ~/.ssh/config)}")

    # Process the array
    local -a host_blocks
    local current_block=""
    for line in "${arr[@]}"; do
        if [[ $line =~ ^Host ]]; then
            if [[ -n $current_block ]]; then
                host_blocks+=("$current_block")
            fi
            current_block="$line"
        elif [[ -n $current_block ]]; then
            current_block+=$'\n'"$line"
        fi
    done

    if [[ -n $current_block ]]; then
        host_blocks+=("$current_block")
    fi

    # Array to store matches
    local -a matches

    for block in "${host_blocks[@]}"; do
        if echo "$block" | grep -q "Hostname $hostname"; then
            local host_alias=$(echo "$block" | awk '/^Host / {print $2}')
            matches+=("$hostname<>$host_alias")
        fi
    done

    echo "${matches[@]}"
    return 0
}

_ssh()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$(grep '^Host' ~/.ssh/config ~/.ssh/config.d/* 2>/dev/null | grep -v '[?*]' | cut -d ' ' -f 2-)

    COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
    return 0
}
complete -F _ssh ssh



show_virtual_env() {
  if [[ -n "$CONDA_DEFAULT_ENV" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename $CONDA_DEFAULT_ENV))"
  fi
}

# prevent duplicate env shown when using both conda activate and direnv together
# PS1='$(show_virtual_env)'$PS1
PS1='$VIRTUAL_ENV_PROMPT'$PS1
export PATH="/opt/homebrew/opt/node@18/bin:$PATH"

fast-git-ssh() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi

    # Get the current origin URL
    local current_url=$(git config --get remote.origin.url)
    if [ -z "$current_url" ]; then
        echo "Error: No origin remote found"
        return 1
    fi

    echo "Current origin URL: $current_url"

    # Extract owner/repo from the current URL
    # This handles formats like:
    # git@gh-work1:owner/repo.git
    # git@github.com:owner/repo.git
    # https://github.com/owner/repo.git
    local repo_path=$(echo "$current_url" | sed -E 's/.*[:/]([^/]+\/[^/]+)\.git$/\1/' | sed -E 's/.*[:/]([^/]+\/[^/]+)$/\1/')
    if [ -z "$repo_path" ]; then
        echo "Error: Could not extract repository path from URL: $current_url"
        return 1
    fi

    echo "Extracted repo path: $repo_path"

    # Extract SSH host from original URL if it's SSH format
    local ssh_host=""
    if [[ "$current_url" == git@*:* ]]; then
        # Extract host using sed
        ssh_host=$(echo "$current_url" | sed -E 's/git@([^:]+):.*/\1/')
        echo "Detected SSH host: $ssh_host"
    else
        # Default to gh-work1 if current URL is not SSH format
        ssh_host="gh-work1"
        echo "Current URL is not SSH format, defaulting to: $ssh_host"
    fi

    # Prepare the new URLs
    local https_url="https://github.com/$repo_path.git"
    local ssh_url="git@$ssh_host:$repo_path.git"

    echo
    echo "This will update the remote URLs to:"
    echo "  Fetch URL: $https_url"
    echo "  Push URL:  $ssh_url"
    echo

    # Ask for user confirmation
    echo -n "Do you want to proceed? [y/N]: "
    read -r REPLY
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Updating remote URLs..."

        # Set fetch URL to HTTPS
        echo "Setting fetch URL to: $https_url"
        git remote set-url origin "$https_url"

        # Set push URL to SSH
        echo "Setting push URL to: $ssh_url"
        git remote set-url --push origin "$ssh_url"

        echo "✅ Remote URLs updated successfully!"
        echo
        echo "Current configuration:"
        git remote -v
    else
        echo "❌ Operation cancelled."
        return 0
    fi
}




# miniconda
# export PATH="$HOME/miniconda3/bin:$PATH"  # commented out by conda initialize
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
# conda activate base_env

# Source wtc function to enable cd behavior
wtc() {
    source ~/.local/bin/wtc "$@"
}
export PATH="$HOME/.deno/bin:$PATH"

# bun completions
[ -s "/Users/jarvis/.bun/_bun" ] && source "/Users/jarvis/.bun/_bun"

unalias cl clr 2>/dev/null
cl() {
    ENABLE_LSP_TOOL=1 claude "$@";
}
clr() { 
    ENABLE_LSP_TOOL=1 claude --resume "$@"; 
}

pi() {
    /Users/jarvis/pi-mono/pi-test.sh "$@"
}
eval "$(mise activate zsh)"

git-push-mirror() {
   echo "[git-push-mirror] Starting"

   if ! git rev-parse --git-dir >/dev/null 2>&1; then
       echo "❌ [git-push-mirror] Error: not in a git repository" >&2
       return 1
   fi

   local mirror_remote="mirror"
   local branch="${1:-$(git rev-parse --abbrev-ref HEAD)}"
   local origin_url
   origin_url="$(git config --get remote.origin.url)"

   echo "[git-push-mirror] Current repo: $(pwd)"
   echo "[git-push-mirror] Target branch: $branch"
   echo "[git-push-mirror] Origin URL: ${origin_url:-<missing>}"

   if [[ -z "$origin_url" ]]; then
       echo "❌ [git-push-mirror] Error: no origin remote found" >&2
       return 1
   fi

   if git config --get "remote.${mirror_remote}.url" >/dev/null 2>&1; then
       local existing_mirror_url
       existing_mirror_url="$(git config --get "remote.${mirror_remote}.url")"
       echo "[git-push-mirror] Existing mirror remote found: $existing_mirror_url"
   else
       local ssh_host owner repo_name inferred_mirror_url

       echo "[git-push-mirror] No mirror remote found, inferring mirror URL from origin"

       if [[ "$origin_url" =~ ^git@([^:]+):([^/]+)/([^/]+)\.git$ ]]; then
           ssh_host="${match[1]}"
           owner="${match[2]}"
           repo_name="${match[3]}"
           inferred_mirror_url="git@${ssh_host}:${owner}/${repo_name}-mirror.git"
           echo "[git-push-mirror] Parsed SSH origin"
       elif [[ "$origin_url" =~ ^https://github\.com/([^/]+)/([^/]+)\.git$ ]]; then
           owner="${match[1]}"
           repo_name="${match[2]}"
           inferred_mirror_url="git@github.com:${owner}/${repo_name}-mirror.git"
           echo "[git-push-mirror] Parsed HTTPS origin"
       else
           echo "❌ [git-push-mirror] Error: unsupported origin URL format: $origin_url" >&2
           return 1
       fi

       echo "[git-push-mirror] Inferred mirror remote URL: $inferred_mirror_url"
       echo "[git-push-mirror] Adding mirror remote"
       git remote add "$mirror_remote" "$inferred_mirror_url"
       echo "[git-push-mirror] Added ${mirror_remote} remote"
   fi

   local mirror_url local_sha remote_sha ahead_count behind_count
   mirror_url="$(git config --get "remote.${mirror_remote}.url")"
   local_sha="$(git rev-parse "$branch")"

   echo "[git-push-mirror] Mirror URL: $mirror_url"
   echo "[git-push-mirror] Checking remote repository availability"

   local ls_remote_error
   ls_remote_error="$(git ls-remote "$mirror_remote" 2>&1 >/dev/null)"
   local ls_remote_exit=$?

   if [[ $ls_remote_exit -ne 0 ]]; then
       echo "❌ [git-push-mirror] Error: mirror remote is configured locally, but the remote repository is not reachable" >&2
       echo "[git-push-mirror] Mirror URL: $mirror_url" >&2
       echo "[git-push-mirror] git ls-remote output:" >&2
       echo "$ls_remote_error" >&2
       echo "[git-push-mirror] Common causes:" >&2
       echo "[git-push-mirror]   - the mirror repo does not exist yet" >&2
       echo "[git-push-mirror]   - the SSH host alias is wrong" >&2
       echo "[git-push-mirror]   - your SSH key does not have access" >&2
       return $ls_remote_exit
   fi

   echo "[git-push-mirror] Remote repository is reachable"
   echo "[git-push-mirror] Checking whether branch '${branch}' exists on ${mirror_remote}"

   git ls-remote --exit-code --heads "$mirror_remote" "$branch" >/dev/null 2>&1
   local remote_branch_status=$?

   if [[ $remote_branch_status -eq 0 ]]; then
       echo "[git-push-mirror] Remote branch exists, fetching for comparison"
       git fetch "$mirror_remote" "$branch" --quiet

       remote_sha="$(git rev-parse "FETCH_HEAD")"
       ahead_count="$(git rev-list --count "${remote_sha}..${branch}")"
       behind_count="$(git rev-list --count "${branch}..${remote_sha}")"

       echo "[git-push-mirror] Local ${branch} SHA:  $local_sha"
       echo "[git-push-mirror] Remote ${branch} SHA: $remote_sha"
       echo "[git-push-mirror] Commits to push:      $ahead_count"
       echo "[git-push-mirror] Commits only remote:   $behind_count"
   elif [[ $remote_branch_status -eq 2 ]]; then
       ahead_count="$(git rev-list --count "$branch")"
       behind_count="0"

       echo "[git-push-mirror] Remote repository exists, but branch '${branch}' does not exist yet"
       echo "[git-push-mirror] Local ${branch} SHA:  $local_sha"
       echo "[git-push-mirror] Commits to push:      $ahead_count"
       echo "[git-push-mirror] This looks like an initial push"
   else
       echo "❌ [git-push-mirror] Error: failed to determine whether branch '${branch}' exists on ${mirror_remote}" >&2
       return $remote_branch_status
   fi

   if [[ "$ahead_count" -eq 0 && "$behind_count" -eq 0 ]]; then
       echo "✅ [git-push-mirror] Mirror is already up to date"
       return 0
   fi

   if [[ "$behind_count" -gt 0 ]]; then
       echo "[git-push-mirror] Warning: remote has commits not in local branch" >&2
       echo "[git-push-mirror] Push may be rejected unless histories are reconciled" >&2
   fi

   echo "[git-push-mirror] Executing: git push ${mirror_remote} ${branch}:${branch}"
   git push "$mirror_remote" "${branch}:${branch}"
   local exit_code=$?

   if [[ $exit_code -ne 0 ]]; then
       echo "❌ [git-push-mirror] Push failed with exit code $exit_code" >&2
       return $exit_code
   fi

   echo "[git-push-mirror] Push succeeded"
   echo "[git-push-mirror] Refreshing remote-tracking branch"
   git fetch "$mirror_remote" "$branch" --quiet

   local new_remote_sha remaining_ahead
   new_remote_sha="$(git rev-parse "FETCH_HEAD")"
   remaining_ahead="$(git rev-list --count "${new_remote_sha}..${branch}")"

   echo "[git-push-mirror] Post-push remote SHA: $new_remote_sha"
   echo "[git-push-mirror] Remaining commits to push: $remaining_ahead"

   if [[ "$new_remote_sha" == "$local_sha" ]]; then
       echo "[git-push-mirror] Local and mirror branch tips match"
   fi

   echo "✅ [git-push-mirror] Done"
}
