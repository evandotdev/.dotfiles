# .dotfiles

# how it works

Place this repo in **$HOME**.
Run the `bootstrap.sh` script to download dependencies.
Install using the `install` script to use stow to place dotfiles into the relevant places, based on shared_vars.
Remove dotfiles using the `clean-env` script.

```
git clone https://github.com/evandotdev/.dotfiles ~
cd ~/.dotfiles
# check `shared_vars` to enable/disable specific installs via stow
./install
```

---

# Command Reference

## Shell Keybindings

| Keybinding | Description | Source |
|------------|-------------|--------|
| **Ctrl-T** | Insert files from fd into command line | FZF |
| **Ctrl-R** | Search command history with FZF | FZF |
| **Alt-C** | Change directory with FZF | FZF |
| **Ctrl-F** | Launch windowizer (cd to projects) | .zshrc:354 |
| **Up Arrow** | Fuzzy search history forward (type prefix first) | .zshrc:55-65 |
| **Down Arrow** | Fuzzy search history backward | .zshrc:55-65 |
| **Ctrl-Left** | Move backward one word | .zshrc:82-84 |
| **Ctrl-Right** | Move forward one word | .zshrc:78-80 |

## Tmux Keybindings

| Keybinding | Description | Source |
|------------|-------------|--------|
| **Option-Q** | Tmux prefix (instead of Ctrl-B) | .tmux.conf:69 |
| **Shift-Left/Right** | Navigate between windows | .tmux.conf:79-80 |
| **Ctrl-Shift-Left/Right** | Move windows left/right | .tmux.conf:89-90 |
| **Prefix + ^** | Jump to last window | .tmux.conf:72 |
| **Prefix + h/j/k/l** | Navigate panes (vim-style) | .tmux.conf:73-76 |
| **Prefix + Opt-Arrows** | Resize panes (repeatable) | .tmux.conf:83-86 |
| **Prefix + g** | Open lazygit popup (80% screen) | .tmux.conf:103 |
| **Prefix + f** | Launch tmux-windowizer | .tmux.conf:129 |
| **Prefix + t** | Launch windowizer for dedicated terminal | .tmux.conf:132 |
| **Prefix + s** | Toggle pane synchronization | .tmux.conf:134-136 |
| **Prefix + B** | Source .zshrc in all panes | .tmux.conf:121-124 |
| **Prefix + r** | Reload tmux config | .tmux.conf:97 |
| **Prefix + x** | Kill pane (no confirmation) | .tmux.conf:93 |
| **Prefix + &** | Kill window (no confirmation) | .tmux.conf:94 |

## Shell Functions

| Function | Description | Source |
|----------|-------------|--------|
| `zf` | Fuzzy find from z (frecency) history and cd | .zshrc:302-305 |
| `windowizer [dir]` | FZF project directory picker | .local/bin/windowizer |
| `tmux-sessionizer [dir]` | Create/switch tmux sessions with FZF | .local/bin/tmux-sessionizer |
| `tmux-windowizer [dir]` | Tmux window manager with FZF | .local/bin/tmux-windowizer |
| `gdf <br1> <br2>` | Show commit differences between branches | .zshrc:246-251 |
| `curbranch` / `cb` | Print current branch name | .zshrc:253-260 |
| `wtc [branch]` | Git worktree creation helper (FZF if no arg) | .local/bin/wtc |
| `wtr [worktree]` | Git worktree removal helper (FZF if no arg) | .local/bin/wtr |
| `fast-git-ssh` | Configure git remote for HTTPS fetch + SSH push | .zshrc:428-503 |
| `conda_remove <env...>` | Remove multiple conda environments | .zshrc:275-280 |
| `use_pg15` / `use_pg16` | Add PostgreSQL 15/16 to PATH | .zshrc:266-272 |
| `daily-commits` | Generate markdown summary of last 24h commits | .local/bin/daily-commits |

## Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| **Navigation** |||
| `fcd` | `cd $(fd --type directory \| fzf)` | cd with FZF |
| `fz` | z history + FZF | cd using frecency |
| `fp` | fzf with preview | FZF with bat/tree preview |
| **Git** |||
| `g` | `git` | Quick git |
| `lgit` | `lazygit` | LazyGit TUI |
| `lzd` | `lazydocker` | LazyDocker TUI |
| **Editor** |||
| `v` | `nvim` | Quick nvim |
| **Quick Commands** |||
| `q` | `exit` | Quick exit |
| `c` | `clear` | Quick clear |
| `ll` | `ls -alFh` | Detailed list |
| `la` | `ls -Aph` | List almost all |
| **File Operations** |||
| `cat` | `bat` with gruvbox | Syntax highlighted cat |
| `cp` | `cp -riv` | Recursive, interactive, verbose |
| `mv` | `mv -iv` | Interactive, verbose |
| `mkdir` | `mkdir -vp` | Create parents, verbose |
| `findfile` | `fd --type=file` | Find files |
| `finddir` | `fd --type=directory` | Find directories |
| `findlink` | `fd --type=link` | Find symlinks |
| **Utilities** |||
| `timestamp` | Copy Unix timestamp | Current timestamp to clipboard |
| `cpl` | Copy last command | Last command to clipboard |
| `oc` | `opencode` | Open in code editor |
| `gpgreset` | Reset GPG agent | Restart GPG agent |
| **Python/Conda** |||
| `python` / `py3` | `python3` | Python 3 |
| `jlab` | `jupyter-lab` | Jupyter Lab |
| `jnb` | `jupyter notebook` | Jupyter Notebook |
| `ae` / `cae` | `conda activate` | Activate conda env |
| `de` / `cde` | `conda deactivate` | Deactivate conda env |

## Git Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| **FZF-Enhanced** |||
| `git a` | Stage with FZF | Interactive staging (multi-select) |
| `git br` | Checkout with FZF | Checkout branch (all branches, deduped) |
| `git bra` | Checkout with FZF | Simple branch checkout |
| `git df` | View commit diff | Select commit from history via FZF |
| **Quick Commands** |||
| `git f` | `fetch --all` | Fetch all remotes |
| `git ps` | Push current branch | Push to origin/current-branch |
| `git psinit` | Push + set upstream | Push and set tracking |
| `git pl` | Pull current branch | Pull from origin/current-branch |
| `git sw` | `switch` | Switch branch |
| `git co` | `checkout` | Checkout branch |
| `git st` | `status` | Repository status |
| `git ci` | `commit` | Commit changes |
| `git cia` | `commit --all` | Commit all changes |
| **Branch Management** |||
| `git brd <br>` | Delete branch | Delete locally and remotely |
| `git bm` | `branch --merged` | List merged branches |
| `git bnm` | `branch --no-merged` | List unmerged branches |
| `git brr` | `branch --remotes` | List remote branches |
| **History & Logs** |||
| `git hist` | Pretty log | Graph with colors |
| `git llog` | Log with status | Detailed log with file changes |
| `git lg` | Pretty log | Beautiful formatted log (lg1/lg2/lg3 variants) |
| `git rl` | `reflog` | Pretty reflog |
| **Stash** |||
| `git sl` | `stash list` | List stashes |
| `git sp` | `stash push` | Stash changes |
| **Utilities** |||
| `git authors` | Show contributors | All contributors with stats |
| `git deepclean` | Hard reset + clean | Reset to HEAD and remove untracked |
| `git open` | Open in browser | Open remote URL in Brave |
| `git rb` | `rebase` | Rebase current branch |
| `git rbc <b> <o>` | Rebase onto | Rebase with custom base |
| `git count-lines <a>` | Count lines | Lines added/removed by author |
| `git count-files <a>` | Count files | Files touched by author |

## FZF Configuration

| Variable | Value | Description |
|----------|-------|-------------|
| `FZF_COMPLETION_TRIGGER` | `**` | Trigger for FZF completion |
| `FZF_DEFAULT_COMMAND` | `rg --files --hidden` | Default file finder |
| `FZF_CTRL_T_COMMAND` | `fd --type file --hidden` | Ctrl-T file finder |

## Most Useful Workflows

1. **Quick Project Switching**: `Ctrl-F` → type name → Enter
2. **Frecency Navigation**: `zf` → select from recent dirs
3. **Interactive Git Staging**: `git a` → tab to select files
4. **Branch Switching**: `git br` → fuzzy find branch
5. **Worktree Management**: `wtc` to create, `wtr` to remove
6. **Tmux Project Windows**: `Prefix + f` → select project
