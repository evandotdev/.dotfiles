# Neovim Configuration

A comprehensive Neovim configuration optimized for modern development workflows with LSP support, fuzzy finding, and enhanced navigation.

## Overview

This configuration uses [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager and is structured in a modular way for easy maintenance and customization.

**Leader Key:** `<Space>`

## Structure

```
.config/nvim/
├── init.lua                          # Main entry point
└── lua/etcy/
    ├── init.lua                      # Bootstrap and VSCode compatibility
    ├── set.lua                       # Core keybindings
    ├── opt.lua                       # Editor options
    ├── autocmd.lua                   # Auto commands
    └── lazy_plugins/                 # Plugin configurations
        ├── fzf.lua                   # Fuzzy finder
        ├── harpoon.lua               # File navigation
        ├── lsp.lua                   # LSP configuration
        ├── git.lua                   # Git integration
        ├── treesitter.lua            # Syntax highlighting
        ├── trouble.lua               # Diagnostics
        ├── copilot.lua               # AI completion
        ├── flash.lua                 # Motion navigation
        ├── files.lua                 # File management
        └── aesthetics.lua            # UI enhancements
```

## Core Editor Settings

### Display
- Line numbers with relative numbering
- 80-character column indicator
- Cursor line highlighting
- True color support
- Sign column always visible (2 columns wide)
- Split windows open to right/below

### Editing
- Tab width: 4 spaces
- Smart indentation enabled
- No swap files
- Persistent undo history
- Auto-read files when changed externally
- Case-insensitive search (smart case enabled)

### Performance
- Update time: 100ms
- Timeout length: 200ms
- Mouse support enabled

## Plugins

### File Navigation & Search

#### FZF-Lua
Fast fuzzy finder powered by fzf.

**Keybindings:**
- `<leader><leader>` or `<leader>fz` - Open FZF menu
- `<leader>ff` - Find files
- `<leader>fb` - Find buffers
- `<leader>fg` - Live grep with glob options
- `<leader>fG` - Live grep
- `<leader>fw` - Grep current word under cursor
- `<leader>f.` - Find recent files in current directory
- `<leader>fc` - Command history
- `<leader>fr` - Resume last search
- `<leader>/` - Fuzzy search in current buffer
- `<leader>vrc` - Find files in $DOTFILES
- `<leader>vrg` - Live grep in $DOTFILES

#### Harpoon
Quick file marking and navigation.

**Keybindings:**
- `<leader>a` - Add file to harpoon
- `<C-e>` - Toggle harpoon menu
- `<A-1>` through `<A-4>` - Jump to harpooned file 1-4
- `<C-S-P>` - Previous harpooned file
- `<C-S-N>` - Next harpooned file

#### Oil.nvim
File explorer as a buffer.

**Keybindings:**
- `-` - Open parent directory in floating window

**Oil Buffer Keybindings:**
- `<CR>` - Select/open
- `<C-s>` - Open in vertical split
- `<C-h>` - Open in horizontal split
- `<C-t>` - Open in new tab
- `<C-p>` - Preview file
- `<C-c>` - Close oil
- `<C-l>` - Refresh
- `g?` - Show help
- `g.` - Toggle hidden files
- `gs` - Change sort order
- `gx` - Open with external program
- `<leader>u` - Discard all changes

### LSP & Completion

#### Language Servers
Configured via Mason:
- **Lua:** lua_ls
- **Go:** gopls
- **Python:** pyright
- **TypeScript/JavaScript:** ts_ls
- **Bash:** bashls
- **Prisma:** prismals

#### Blink.cmp
Fast completion engine with snippet support.

**Keybindings:**
- `<C-y>` - Accept completion
- `<C-j>` / `<C-n>` - Next item
- `<C-k>` / `<C-p>` - Previous item
- `<C-b>` - Scroll documentation up
- `<C-f>` - Scroll documentation down
- `<C-space>` - Show snippets
- `<Tab>` - Accept Copilot suggestion (when shown)

#### LSP Keybindings
Available when LSP is attached:

**Navigation:**
- `gd` - Go to definitions (FZF)
- `gr` - Go to references (FZF)
- `gi` - Go to implementations (FZF)
- `gt` - Go to type definitions (FZF)
- `<leader>gd` - Go to declaration
- `K` - Show hover documentation
- `<leader>fs` - Search workspace symbols

**Diagnostics:**
- `[d` / `]d` - Previous/next diagnostic
- `[e` / `]e` - Previous/next error
- `[w` / `]w` - Previous/next warning
- `<leader>vd` - Open diagnostic float

**Code Actions:**
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol
- `<leader>fm` - Format buffer

**References:**
- `[r` / `]r` - Previous/next reference (vim-illuminate)

#### Formatters & Linters
Auto-installed via Mason:
- **Lua:** stylua
- **Go:** gofumpt, goimports, golines, golangci-lint
- **Python:** ruff
- **TypeScript/JavaScript:** prettierd
- **Bash:** shfmt, shellcheck
- **JSON:** jq

### Git Integration

#### Gitsigns
Git integration with inline blame and hunk operations.

**Keybindings:**
- `[c` / `]c` - Previous/next git change
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk
- `<leader>hS` - Stage buffer
- `<leader>hR` - Reset buffer
- `<leader>hp` - Preview hunk
- `<leader>hi` - Preview hunk inline
- `<leader>hb` - Blame line (full)
- `<leader>hd` - Diff this
- `<leader>hD` - Diff this ~
- `<leader>hq` - Send hunks to quickfix
- `<leader>hQ` - Send all hunks to quickfix
- `<leader>tb` - Toggle current line blame
- `<leader>tw` - Toggle word diff

**Text Objects:**
- `ih` - Select git hunk (in visual/operator mode)

### Motion & Navigation

#### Flash.nvim
Enhanced motion and search with labels.

**Keybindings:**
- `<leader>s` - Flash jump
- `<leader>S` - Flash treesitter
- `r` - Remote flash (operator mode)
- `R` - Treesitter search (operator/visual mode)
- `<leader>tf` - Toggle flash search (command mode)

**Enhanced f/t motions:**
After `f{char}` or `t{char}`:
- `f` / `F` - Repeat forward/backward
- `t` / `T` - Repeat forward/backward
- `;` - Next match
- `,` - Previous match

### Diagnostics & Quickfix

#### Trouble
Enhanced diagnostics and quickfix viewer.

**Keybindings:**
- `<leader>tt` - Toggle diagnostics (all files in project)
- `<leader>tT` - Toggle buffer diagnostics
- `<leader>ts` - Toggle symbols
- `<leader>tl` - LSP definitions/references
- `<leader>l` - Location list
- `<leader>qf` - Quickfix list

### AI Assistance

#### Copilot
GitHub Copilot integration.

**Keybindings:**
- `<Tab>` - Accept suggestion
- `<M-]>` - Next suggestion
- `<M-[>` - Previous suggestion
- `<C-c>` - Dismiss suggestion
- `<M-CR>` - Open panel
- `<leader>tc` - Toggle Copilot auto-trigger

**Panel Keybindings:**
- `<Tab>` - Accept
- `gr` - Refresh
- `[[` - Previous suggestion
- `]]` - Next suggestion

### Code Documentation

#### Docstring Generation

**Python:**
- `<leader>dg` - Generate Python docstring (Google style)

**Multiple Languages:**
- `<leader>ng` - Generate documentation (Neogen)

### UI & Aesthetics

#### Theme
- **Colorscheme:** Tokyo Night

#### Lualine
Status line with mode, git branch, diagnostics, and file info.

#### Incline
Floating filename labels with git status and diagnostics.

#### Dropbar
Winbar showing code context breadcrumbs.

**Keybindings:**
- `<leader>;` - Pick symbols in winbar
- `[;` - Go to start of current context
- `];` - Select next context

#### Todo Comments
Enhanced TODO/FIXME/NOTE highlighting.

**Supported Keywords:**
- `TODO` - General todos
- `FIX`, `FIXME`, `BUG`, `ISSUE` - Things to fix
- `HACK` - Hacky solutions
- `WARN`, `WARNING`, `XXX` - Warnings
- `PERF`, `OPTIM`, `OPTIMIZE` - Performance improvements
- `NOTE`, `INFO` - Notes and information
- `TEST`, `TESTING`, `PASSED`, `FAILED` - Testing related

**Keybindings:**
- `]t` / `[t` - Next/previous TODO comment

#### Other UI Plugins
- **nvim-surround:** Manipulate surrounding pairs (quotes, brackets, etc.)
- **vim-illuminate:** Highlight word under cursor
- **guess-indent:** Automatically detect indentation
- **indent-blankline:** Show indentation guides

### Treesitter

Enhanced syntax highlighting and text objects.

**Text Objects:**
- `af` / `if` - Around/inside function
- `ac` / `ic` - Around/inside class
- `as` - Around scope

**Incremental Selection:**
- `v` - Expand selection (in visual mode)
- `V` - Shrink selection (in visual mode)

## Core Keybindings

### General

**Mode Switching:**
- `<C-c>` - Escape (works in all modes)

**Window Navigation:**
- `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` - Move focus to left/down/up/right window

**Window Splitting:**
- `sh` - Split horizontal
- `sv` - Split vertical
- `sc` - Close all splits except current

**Buffer Navigation:**
- `<Tab>` - Next buffer
- `<S-Tab>` - Previous buffer

**Wrapped Lines:**
- `j` / `k` - Move down/up respecting wrapped lines

**Scrolling:**
- `<C-d>` - Scroll down 10 lines (centered)
- `<C-u>` - Scroll up 10 lines (centered)

**Search:**
- `n` / `N` - Next/previous match (centered)
- `<Esc>` - Clear search highlights

**Miscellaneous:**
- `<Esc><Esc>` - Exit terminal mode

### Editing

**Line Movement:**
- `<leader>j` - Move line down (normal mode)
- `<leader>k` - Move line up (normal mode)
- `J` - Move selection down (visual mode)
- `K` - Move selection up (visual mode)

**Line Joining:**
- `<leader>J` - Join lines without moving cursor

**Yanking:**
- `Y` - Yank to end of line
- `<leader>y` - Yank to system clipboard
- `<leader>Y` - Yank line to system clipboard

**Deleting without Yanking:**
- `<leader>d` - Delete without yanking
- `<leader>D` - Delete to end of line without yanking
- `<leader>x` - Delete character without yanking

**Pasting:**
- `<leader>p` - Paste over selection without yanking (visual mode)

**Indenting:**
- `<` / `>` - Decrease/increase indent (maintains selection in visual mode)

**Duplicating:**
- `D` - Duplicate selection below (visual mode)

**Undo:**
- `<leader>u` - Toggle undo tree

### Command Line

**Navigation in Command Mode:**
- `<C-h>` / `<C-l>` - Left/right
- `<C-j>` / `<C-k>` - Down/up (history)
- `^` - Beginning of line
- `$` - End of line

### Quickfix & Location Lists

- `]q` / `[q` - Next/previous quickfix item

### Toggle Commands

- `<leader>td` - Toggle diagnostics
- `<leader>th` - Toggle inlay hints
- `<leader>tc` - Toggle Copilot
- `<leader>tb` - Toggle git blame
- `<leader>tw` - Toggle word diff

### Which-Key

- `<leader>?` - Show buffer-local keymaps

## Custom Commands

### Buffer Management
- `:CloseAllButCurrent` - Close all buffers except current

### Quickfix
- `:QuickFixClear` - Clear quickfix list
- `:QuickFixUndo` - Undo changes in quickfix list

### Marks
- `:ClearMarks` - Clear all marks

## Auto Commands

### On Save
- Auto-format buffer using conform.nvim
- Remove trailing whitespace
- Remove unused TypeScript imports

### On Buffer Enter
- Auto-reload if file changed externally

### On Yank
- Highlight yanked text briefly (150ms)

### Format Options
- Enable `c` and `r` format options (continue comments on Enter)
- Disable `o` format option (don't continue comments with o/O)

## VSCode Compatibility

This configuration includes VSCode-specific keybindings when running in VSCode Neovim extension. The configuration automatically detects VSCode and adjusts accordingly.

## Language-Specific Features

### Go
- Auto-format on save with gofumpt, goimports, golines
- golangci-lint diagnostics
- Code actions: impl, gomodifytags
- Inlay hints for types and parameters

### Python
- Auto-format with ruff
- Pyright type checking (strict mode)
- Auto f-string conversion
- Python import management (Pymple)
- Google-style docstrings

### TypeScript/JavaScript
- Format with prettierd/prettier
- Auto-remove unused imports
- Inlay hints for types and parameters

### Lua
- Format with stylua
- Neovim Lua API completion with lazydev

### Bash
- Format with shfmt
- Diagnostics with shellcheck

## Requirements

### System Dependencies
- Neovim >= 0.10
- Git
- Node.js >= 20 (for Copilot)
- [fzf](https://github.com/junegunn/fzf)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fd](https://github.com/sharkdp/fd) (optional, for faster file finding)
- A [Nerd Font](https://www.nerdfonts.com/) for icons

### Environment Variables
The configuration sources encrypted API keys:
- `ANTHROPIC_API_KEY` - From `~/.anthropic-api-key.enc`
- `OPENROUTER_API_KEY` - From `~/.openrouter-api-key.enc`

These are decrypted using `sops`.

## Installation

1. Backup existing config:
```bash
mv ~/.config/nvim ~/.config/nvim.backup
```

2. Clone or link this configuration:
```bash
ln -s ~/.dotfiles/nvim/.config/nvim ~/.config/nvim
```

3. Start Neovim - lazy.nvim will automatically install plugins:
```bash
nvim
```

4. Install LSP servers and tools:
```vim
:Mason
```

## Tips

### Quickfix Workflow
1. Search with `<leader>fg` (live grep)
2. Send results to quickfix with `<Alt-q>`
3. Navigate with `]q` / `[q`
4. View in Trouble with `<leader>qf`

### Harpoon Workflow
1. Mark important files with `<leader>a`
2. Toggle menu with `<C-e>` to manage marks
3. Jump instantly with `<A-1>` through `<A-4>`

### Flash Navigation
1. Press `<leader>s` to activate flash
2. Type 1-2 characters to narrow down
3. Type the label shown to jump

### LSP Navigation
1. Use `gd` to explore definitions
2. Use `gr` to find all references
3. Use `<leader>ca` for available code actions
4. Use `K` for documentation
5. Navigate diagnostics with `]d` / `[d`

## Customization

Edit files in `lua/etcy/lazy_plugins/` to customize plugin configurations. Each plugin is in its own file for easy modification.
