# dotfiles

Personal macOS dotfiles: zsh (oh-my-zsh) + Neovim, symlinked into place via `install.sh`.

## Layout

```
.zshrc                    -> ~/.zshrc
nvim/.config/nvim/         -> ~/.config/nvim
ohmyzsh/.oh-my-zsh/         (legacy copy; the active oh-my-zsh install manages itself separately)
install.sh                 bootstrap script for a new machine
```

## New machine setup

This repo is public, so getting it onto a new machine needs no credentials:

```bash
git clone https://github.com/jacwynn/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` is idempotent (safe to re-run) and:
- symlinks `.zshrc` and the nvim config into place
- installs Xcode Command Line Tools / Homebrew if missing
- installs `neovim`, `git`, `ripgrep`, `fd`, `tree-sitter-cli`, and a Nerd Font
- installs `nvm` + Node LTS if missing
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
- Formatting: prettier/prettierd wired up for html/css/scss/js/ts/json, format-on-save enabled for those plus lua
- Treesitter: added css/scss/javascript/typescript/tsx/json parsers
- `lua/custom/filetype.lua`: maps `.isml` (SFCC template files) to the `html` filetype
- `lua/custom/plugins/dw-sync.lua`: `nvim_dw_sync` — Telescope-based cartridge upload for Demandware. Has two known upstream bugs (see the comment in that file); workaround is documented there.
- Two personal keymaps: `;` → `:`, `jk` → `<Esc>` (insert mode)

**Known quirks (see comments in `init.lua` for detail):**
- nvim-treesitter's `main` branch has been observed serving two different, incompatible APIs across reinstalls — the config detects which one is present at runtime and uses that, rather than assuming one.
- `mason-lspconfig`'s registry refresh can occasionally throw a background (non-fatal) error if it and `mason.nvim` fall out of sync with each other. Doesn't block anything else from loading; if LSP servers aren't auto-installing, run `:Mason` manually.

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
