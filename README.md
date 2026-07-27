# dotfiles

Personal macOS dotfiles: zsh (oh-my-zsh) + Neovim + tmux, symlinked into place via `install.sh`.

## Layout

```
.zshrc                    -> ~/.zshrc
.tmux.conf                -> ~/.tmux.conf
nvim/.config/nvim/         -> ~/.config/nvim
install.sh                 bootstrap script for a new machine
```

oh-my-zsh itself (`~/.oh-my-zsh`) is not tracked here — it's a separate, self-updating install (its own git clone), managed by oh-my-zsh's own installer/updater rather than this repo.

Similarly, `~/.tmux` is not tracked here — `.tmux.conf` hardcodes TPM (the tmux plugin manager) to live at `~/.tmux/plugins/tpm`, so that directory is just TPM's install location, not a framework this config depends on. `install.sh` clones TPM there if it's missing.

## New machine setup

This repo is public, so getting it onto a new machine needs no credentials:

```bash
git clone https://github.com/jacwynn/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` is idempotent (safe to re-run) and:
- symlinks `.zshrc`, `.tmux.conf`, and the nvim config into place
- installs Xcode Command Line Tools / Homebrew if missing
- installs `neovim`, `git`, `ripgrep`, `fd`, `tree-sitter-cli`, `tmux`, and a Nerd Font
- installs `nvm` + Node LTS if missing
- clones TPM (tmux plugin manager) if missing — after that, start tmux and press `<prefix> + I` once to install the actual plugin list
- checks whether SSH/`gh` push access to GitHub is actually working

Read the comment block at the top of `install.sh` for SSH key setup if you want to push from a new machine (a plain clone only needs to pull).

### If the machine's default GitHub account isn't jacwynn

The HTTPS clone above works regardless (public repo, no auth needed to pull). Push access needs a second SSH identity scoped just to this repo, via an SSH config host alias:

```bash
ssh-keygen -t ed25519 -C "jacwynn key" -f ~/.ssh/id_ed25519_jacwynn

# add to ~/.ssh/config:
Host github.com-jacwynn
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_jacwynn

# paste ~/.ssh/id_ed25519_jacwynn.pub into github.com/settings/keys (jacwynn's account)

git clone git@github.com-jacwynn:jacwynn/dotfiles.git ~/dotfiles
# or, if already cloned via HTTPS:
git remote set-url origin git@github.com-jacwynn:jacwynn/dotfiles.git
```

**SFCC/Demandware work:** sandbox credentials live in a per-project `dw.json`, never in this repo. Create one in each SFCC project's root — see the [nvim_dw_sync README](https://github.com/3mpee3mpee/nvim_dw_sync) for the expected format.

## Neovim setup

Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), pinned to the last commit before it migrated to Neovim's native `vim.pack` plugin manager (`cd7adee3`) — this keeps it on `lazy.nvim`, matching most kickstart tutorials/community content, and only needs Neovim 0.11+ rather than 0.12+.

**Customizations on top of stock kickstart:**
- LSP: added `ts_ls`, `html`, `cssls`, `jsonls` (stock kickstart only ships `lua_ls`)
- Formatting: prettier/prettierd wired up for html/css/scss/js/ts/json, format-on-save enabled for those plus lua — except inside SFCC/Demandware projects (detected via `dw.json` anywhere up the buffer's directory tree), where format-on-save is skipped entirely since prettier's defaults fight the project's own lint rules. Manual `<leader>f` still works there.
- Treesitter: added css/scss/javascript/typescript/tsx/json parsers
- Enabled kickstart's optional `nvim-autopairs` (auto-closes `()`, `""`, `''`, etc as you type)
- Gitsigns: enabled the recommended keymaps (git blame, hunk staging/reset/preview, diffs) — folded directly into the one gitsigns spec in `init.lua` rather than kept as a separate file, since declaring the same plugin twice at the top level was found to silently drop the custom sign icons instead of merging (see the NOTE above that spec)
- `lua/custom/filetype.lua`: maps `.isml` (SFCC template files) to the `html` filetype
- `lua/custom/plugins/dw-sync.lua`: `nvim_dw_sync` — Telescope-based cartridge upload for Demandware. Has two known upstream bugs (see the comment in that file); workaround is documented there.
- Two personal keymaps: `;` → `:`, `jk` → `<Esc>` (insert mode)

**Known quirks (see comments in `init.lua` for detail):**
- nvim-treesitter's `main` branch has been observed serving two different, incompatible APIs across reinstalls — the config detects which one is present at runtime and uses that, rather than assuming one.
- `mason-lspconfig`'s registry refresh can occasionally throw a background (non-fatal) error if it and `mason.nvim` fall out of sync with each other. Doesn't block anything else from loading; if LSP servers aren't auto-installing, run `:Mason` manually.
- Declaring the same plugin twice at the top level of the `require('lazy').setup({...})` list does not reliably deep-merge `opts` — test it before assuming it will.

### Commands — the 80/20

Leader is `<space>`. Two mnemonics cover most of it: **`<leader>s...`** = Search (Telescope), **`gr...`** = Goto/LSP.

**Files & search**
| Key | Action |
|---|---|
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep |
| `<leader>sw` | Grep word under cursor |
| `<leader><leader>` | Switch buffers |
| `<leader>/` | Fuzzy search current buffer |
| `<leader>s.` | Recent files |
| `<leader>sd` | Search diagnostics |
| `<leader>sh` | Search help |
| `<leader>sk` | Search keymaps |

**LSP** (once attached — check `:LspInfo`)
| Key | Action |
|---|---|
| `grd` | Go to definition |
| `grr` | Find references |
| `gri` | Go to implementation |
| `grn` | Rename symbol |
| `gra` | Code action |
| `gO` | Document symbols |
| `<leader>th` | Toggle inlay hints |
| `K` | Hover docs |

**Editing**
| Key | Action |
|---|---|
| `<leader>f` | Format buffer |
| `saiw)` | Surround add — wrap word in `()` |
| `sd'` | Surround delete `'` |
| `sr)'` | Surround replace `)` → `'` |
| `<C-y>` (insert) | Accept completion |
| `jk` (insert) | `<Esc>` |
| `;` (normal) | `:` |
| `(`, `"`, `'`, etc | Auto-closed in pairs as you type (nvim-autopairs) |

**Git (gitsigns)** — like GitLens' inline blame, built in rather than a separate plugin
| Key | Action |
|---|---|
| `<leader>hb` | Blame current line (full popup) |
| `<leader>tb` | Toggle inline blame (shows on every line, like GitLens) |
| `<leader>hp` | Preview hunk diff |
| `<leader>hs` / `<leader>hr` | Stage / reset hunk |
| `<leader>hS` / `<leader>hR` | Stage / reset whole buffer |
| `<leader>hd` / `<leader>hD` | Diff against index / last commit |
| `]c` / `[c` | Jump to next / previous change |

**Windows & general**
| Key | Action |
|---|---|
| `<C-h/j/k/l>` | Move between splits |
| `<leader>q` | Diagnostics to quickfix |
| `<Esc>` | Clear search highlight |
| `<leader>ds` | SFCC: DW Sync picker (upload cartridges) |

**Commands (typed, not keymaps)**
| Command | Use |
|---|---|
| `:Lazy` | Plugin manager status/updates |
| `:Mason` | Manage LSP servers/formatters |
| `:checkhealth` | Diagnose setup problems |
| `:LspInfo` | LSP attached to current buffer |

If you forget everything else: hit `<leader>` and wait — `which-key` shows every available keybind live from wherever your cursor is.

## Tmux setup

Prefix is remapped to **`C-s`** (not the default `C-b`). Plugins via TPM: `vim-tmux-navigator`, `tmux-themepack`, `tmux-resurrect`, `tmux-continuum`.

**If `C-h/j/k/l` pane navigation isn't working**, TPM cloning itself (which `install.sh` does) is not the same as installing the plugins it manages — that needs one manual step: start tmux and press `<prefix> + I` (capital I) to have TPM actually fetch `vim-tmux-navigator` and the others. Check `ls ~/.tmux/plugins/vim-tmux-navigator` if unsure whether it's already installed.

**Windows**
| Key | Action |
|---|---|
| `C-s c` | New window |
| `C-s n` | Next window |
| `C-s w` | Interactive list of all windows |
| `C-s <number>` | Jump to window N (e.g. `C-s 2`) |
| `C-s ,` | Rename current window |
| `C-s &` | Kill current window |
| `C-s C-s` | Jump to last active window (custom — double-tap prefix) |

Note: the tmux default `C-s p` (previous window) is **not** available here — `p` is rebound to paste-buffer (see Copy mode below). Use `C-s w` or a window number instead.

**Panes**
| Key | Action |
|---|---|
| `C-s \|` | Split pane vertically (side by side) — custom |
| `C-s -` | Split pane horizontally (stacked) — custom |
| `C-h` / `C-j` / `C-k` / `C-l` | Move between panes — **no prefix needed**. Also moves between nvim splits with the same keys (vim-tmux-navigator detects when the active pane is running nvim and hands off to nvim's own `<C-h/j/k/l>` maps) |
| `C-s h/j/k/l` | Resize active pane (repeatable — keep tapping within the timeout) |
| `C-s m` | Toggle pane zoom (fullscreen) — custom |
| `C-s x` | Kill current pane |

**Copy mode / misc**
| Key | Action |
|---|---|
| `C-s [` | Enter copy mode |
| `v` (in copy mode) | Begin selection — custom, vi-style |
| `y` (in copy mode) | Copy selection — custom |
| `C-s p` | Paste buffer — custom (not the tmux default previous-window) |
| `C-s r` | Reload `~/.tmux.conf` — custom |
| `C-k` | Clear scrollback history — custom, no prefix |
