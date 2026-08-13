# Neovim

Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), pinned to the last commit before it migrated to Neovim's native `vim.pack` plugin manager (`cd7adee3`) — this keeps it on `lazy.nvim`, matching most kickstart tutorials/community content, and only needs Neovim 0.11+ rather than 0.12+.

## Customizations on top of stock kickstart

- LSP: added `ts_ls`, `html`, `cssls`, `jsonls`, `emmet_language_server` (stock kickstart only ships `lua_ls`). Emmet abbreviations (e.g. type `p`, expand to `<p></p>`) show up as ordinary completion items in the `blink.cmp` popup — accept with `<C-y>` like any other suggestion, no separate plugin/keybinding needed.
- `lua/custom/snippets/isml/isml.json`: ISML tag snippets (`isif`, `isloop`, `isset`, etc) loaded via LuaSnip's VS Code-format loader — Emmet-style completion for SFCC's own tags, which Emmet doesn't know about. See [sfcc.md](sfcc.md).
- `after/queries/html/highlights.scm`: recolors ISML tag names (`isif`, `isloop`, etc) as `@keyword` instead of plain `@tag`, so they read as SFCC's own control-flow tags rather than markup. See [sfcc.md](sfcc.md).
- `lua/custom/isml-expr-highlight.lua`: real JavaScript syntax highlighting for ISML's embedded `${...}` script expressions, wherever they appear (attribute values, mixed with literal text, or standalone page text) — scoped to `.isml` files only. See [sfcc.md](sfcc.md).
- Formatting: prettier/prettierd wired up for html/css/scss/js/ts/json, format-on-save enabled for those plus lua — except inside SFCC/Demandware projects, where it's skipped entirely (see [sfcc.md](sfcc.md)). Manual `<leader>f` still works there.
- Treesitter: added css/scss/javascript/typescript/tsx/json parsers
- Enabled kickstart's optional `nvim-autopairs` (auto-closes `()`, `""`, `''`, etc as you type)
- Added `lukas-reineke/indent-blankline.nvim` — vertical lines through each indent level, plus scope highlighting that underlines the start/end line of whatever block the cursor is in (e.g. put the cursor inside a `<div>`'s contents and both its opening and closing tag get underlined) — makes nested divs/braces/ISML blocks easy to trace visually.
- Gitsigns: enabled the recommended keymaps (git blame, hunk staging/reset/preview, diffs) — folded directly into the one gitsigns spec in `init.lua` rather than kept as a separate file, since declaring the same plugin twice at the top level was found to silently drop the custom sign icons instead of merging (see the NOTE above that spec)
- Added `christoomey/vim-tmux-navigator` (the Neovim-side half — the tmux-side half is installed via TPM, see [tmux.md](tmux.md)) and removed kickstart's plain `<C-w><C-h>`-style window-nav keymaps in favor of it, so `C-h/j/k/l` seamlessly move between nvim splits *and* tmux panes with the same keys, including handing off back to tmux at a split boundary
- Auto-reload buffers changed outside Neovim (e.g. by an AI coding tool): `autoread` on, plus `:checktime` on `FocusGained`/`BufEnter`/`CursorHold`/`CursorHoldI` so it's caught both when switching back into Neovim and while sitting in the same window. A notify fires so a reload isn't silent. Requires `focus-events on` in `.tmux.conf` for the `FocusGained` half to work inside tmux (see [tmux.md](tmux.md)) — without it, tmux swallows terminal focus events entirely.
- `lua/custom/filetype.lua`: maps `.isml` (SFCC template files) to the `html` filetype
- `lua/custom/sfcc-editorconfig.lua`: skips editorconfig's `trim_trailing_whitespace` inside SFCC projects (see [sfcc.md](sfcc.md))
- `lua/custom/plugins/dw-sync.lua`: `nvim_dw_sync` — Telescope-based cartridge upload for Demandware (see [sfcc.md](sfcc.md))
- `lua/custom/plugins/harpoon.lua`: `harpoon` (harpoon2 branch) — mark a small working set of files and jump straight to them, instead of cycling through buffers. See [Harpoon](#harpoon) below.
- `lua/custom/plugins/dap.lua`: `nvim-dap` + `nvim-dap-ui` — debugging (VS Code launch.json equivalent), including a custom SFCC/Demandware adapter. See [debugging.md](debugging.md).
- `lua/custom/plugins/toggleterm.lua`: `toggleterm.nvim` — `<leader>tt` toggles a floating terminal for one-off shell commands (`git pull`, running a dev server, `lazygit`, etc) without leaving Neovim. It's persistent: toggling it away and back keeps scrollback and any running process.
- Two personal keymaps: `;` → `:`, `jk` → `<Esc>` (insert mode)
- Visual mode `<`/`>` reselect the selection after shifting indent (`<gv`/`>gv`), so either can be tapped repeatedly to indent/outdent multiple levels in one go — closer to VS Code's Cmd+[/Cmd+] than vim's default (which drops back to normal mode and deselects after a single shift)
- Code folding: `foldmethod=expr` + `vim.treesitter.foldexpr()` (built into Neovim core, not the nvim-treesitter plugin, so unaffected by that plugin's classic-vs-new API split above) instead of the useless default `foldmethod=manual`. `foldlevelstart=99` so files open fully expanded. See [Folding](#folding) below.

## Known quirks

(see comments in `init.lua` for detail)

- nvim-treesitter's `main` branch has been observed serving two different, incompatible APIs across reinstalls — the config detects which one is present at runtime and uses that, rather than assuming one.
- `mason-lspconfig`'s registry refresh can occasionally throw a background (non-fatal) error if it and `mason.nvim` fall out of sync with each other. Doesn't block anything else from loading; if LSP servers aren't auto-installing, run `:Mason` manually.
- Declaring the same plugin twice at the top level of the `require('lazy').setup({...})` list does not reliably deep-merge `opts` — test it before assuming it will.

## Commands — the 80/20

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
| `<C-y>` (insert, completion menu open) | Accept completion |
| `<` / `>` (visual) | Outdent/indent selection, reselect for repeat shifts |
| `gcc` | Comment out current line (toggle) |
| `gc` + motion, or visual `gc` | Comment out a range (toggle) |
| `jk` (insert) | `<Esc>` |
| `;` (normal) | `:` |
| `(`, `"`, `'`, etc | Auto-closed in pairs as you type (nvim-autopairs) |

**Git (gitsigns)** — like GitLens' inline blame, built in rather than a separate plugin
| Key | Action |
|---|---|
| `<leader>gs` | Telescope git status — every changed file at once, live diff preview (`<C-u>`/`<C-d>` to scroll it) |
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
| `<C-h/j/k/l>` | Move between splits (and tmux panes — see [tmux.md](tmux.md)) |
| `<C-w>v` / `<C-w>s` | Split vertically / horizontally |
| `<C-w>c` / `:q` | Close current split only |
| `<C-w>o` | Close every split except the current one |
| `<C-^>` | Jump to the alternate (previously edited) buffer |
| `<C-o>` / `<C-i>` | Back/forward through the jump list |
| `<leader>q` | Diagnostics to quickfix |
| `<Esc>` | Clear search highlight |
| `<leader>ds` | SFCC: DW Sync picker (upload cartridges) — see [sfcc.md](sfcc.md) |
| `<leader>tt` | Toggle floating terminal (persistent — keeps scrollback/running process) |

**Commands (typed, not keymaps)**
| Command | Use |
|---|---|
| `:Lazy` | Plugin manager status/updates |
| `:Mason` | Manage LSP servers/formatters |
| `:checkhealth` | Diagnose setup problems |
| `:LspInfo` | LSP attached to current buffer |
| `:e path/to/file` | Create/open a new file |
| `:Explore` (or `:Ex`) | Open netrw file explorer in the current buffer's directory — `%` creates a file, `d` creates a directory |

If you forget everything else: hit `<leader>` and wait — `which-key` shows every available keybind live from wherever your cursor is.

## Harpoon

Mark a small working set of files (e.g. everything touched while building one feature) and jump straight to any of them — faster than cycling through `<leader><leader>` buffers or `:bnext`/`:bprev` once that list gets long.

| Key | Action |
|---|---|
| `<leader>a` | Add current file to the harpoon list |
| `<C-e>` | Toggle the quick-menu (view/reorder/remove marks) |
| `<leader>1` .. `7` | Jump straight to marked file 1–7 |

Harpoon's own README suggests `<C-h>` and `<C-s>` for jumping to marks — neither works here: `<C-h>` is already `vim-tmux-navigator`'s move-left, and `<C-s>` is the tmux prefix key, so tmux swallows it before nvim ever sees it. Using `<leader>1-7` instead sidesteps both.

## Folding

Folds are based on actual code structure (functions, blocks, tags — via `vim.treesitter.foldexpr()`), not indentation guessing. Files open fully expanded (`foldlevelstart=99`); all standard vim fold commands work, no extra plugin or keymap needed:

| Key | Action |
|---|---|
| `za` | Toggle the fold under the cursor |
| `zc` / `zo` | Close / open the fold under the cursor |
| `zM` | Close all folds — good for seeing a file's high-level shape |
| `zR` | Open all folds |
| `zj` / `zk` | Jump to the next / previous fold |
| `zA` | Toggle recursively (fold + everything nested inside it) |
