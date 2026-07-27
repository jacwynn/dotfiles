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
- Added `christoomey/vim-tmux-navigator` (the Neovim-side half — the tmux-side half is installed via TPM, see Tmux setup below) and removed kickstart's plain `<C-w><C-h>`-style window-nav keymaps in favor of it, so `C-h/j/k/l` seamlessly move between nvim splits *and* tmux panes with the same keys, including handing off back to tmux at a split boundary
- `lua/custom/filetype.lua`: maps `.isml` (SFCC template files) to the `html` filetype
- `lua/custom/plugins/dw-sync.lua`: `nvim_dw_sync` — Telescope-based cartridge upload for Demandware. Has two known upstream bugs (see the comment in that file); workaround is documented there.
- `lua/custom/plugins/harpoon.lua`: `harpoon` (harpoon2 branch) — mark a small working set of files and jump straight to them, instead of cycling through buffers. See Harpoon section below for keymaps and why its own suggested defaults (`<C-h>`, `<C-s>`) don't work in this setup.
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

### Harpoon

Mark a small working set of files (e.g. everything touched while building one feature) and jump straight to any of them — faster than cycling through `<leader><leader>` buffers or `:bnext`/`:bprev` once that list gets long.

| Key | Action |
|---|---|
| `<leader>a` | Add current file to the harpoon list |
| `<C-e>` | Toggle the quick-menu (view/reorder/remove marks) |
| `<leader>1` .. `7` | Jump straight to marked file 1–7 |

Harpoon's own README suggests `<C-h>` and `<C-s>` for jumping to marks — neither works here: `<C-h>` is already `vim-tmux-navigator`'s move-left, and `<C-s>` is the tmux prefix key, so tmux swallows it before nvim ever sees it. Using `<leader>1-4` instead sidesteps both.

## Tmux setup

Prefix is remapped to **`C-s`** (not the default `C-b`). Plugins via TPM: `vim-tmux-navigator`, `tmux-themepack`, `tmux-resurrect`, `tmux-continuum`.

`vim-tmux-navigator` has two halves that both need to be present for seamless `C-h/j/k/l` navigation across both tmux panes and nvim splits:
- **tmux-side**: installed via TPM (`~/.tmux/plugins/vim-tmux-navigator`). If pane navigation does nothing at all (all four directions), TPM cloning itself (which `install.sh` does) is not the same as installing the plugins it manages — start tmux and press `<prefix> + I` (capital I) to have TPM actually fetch it.
- **nvim-side**: installed as a regular nvim plugin (`christoomey/vim-tmux-navigator` in `init.lua`). If navigation *into* an nvim pane works but you can't navigate back *out* of it, this half is missing or nvim's own `<C-w><C-h>`-style maps are shadowing it — nvim's plain window-nav keymaps only move within nvim's own splits and don't know how to hand off back to tmux at a split boundary.

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
| `C-h` / `C-j` / `C-k` / `C-l` | Move between panes — **no prefix needed**. Also moves between nvim splits with the same keys, including handing back off to tmux at a split boundary (both halves of vim-tmux-navigator — tmux-side and nvim-side — required, see note above) |
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
