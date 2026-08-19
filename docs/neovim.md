# Neovim

Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), pinned to the last commit before it migrated to Neovim's native `vim.pack` plugin manager (`cd7adee3`) — this keeps it on `lazy.nvim`, matching most kickstart tutorials/community content, and only needs Neovim 0.11+ rather than 0.12+.

## Customizations on top of stock kickstart

- LSP: added `ts_ls`, `html`, `cssls`, `jsonls`, `emmet_language_server` (stock kickstart only ships `lua_ls`). Emmet abbreviations (e.g. type `p`, expand to `<p></p>`) show up as ordinary completion items in the `blink.cmp` popup — accept with `<C-y>` like any other suggestion, no separate plugin/keybinding needed.
- `blink.cmp`'s `sources.default` adds `'buffer'` alongside stock kickstart's `lsp`/`path`/`snippets` — fuzzy-matches words already present in visible buffers, independent of LSP semantics. Covers cases the LSP source can't: an ISML template variable declared with `<isset name="defaultName" .../>` and referenced later as `${defaultName}` never gets LSP completion (the `html` LSP has no idea ISML's `isset` exists), but it's still plain text sitting in the buffer once typed once, so the buffer source picks it up.
- Telescope: `path_display = { 'filename_first' }` (filename first, dimmed directory second, so a long path never buries the filename — see the `mini.statusline` bullet below for the same idea there) and `initial_mode = 'normal'` (every picker opens in Normal mode instead of Telescope's default Insert mode — press `i` when you actually want to type a query). Both set in `defaults`, so they apply to every builtin picker and theme (find_files, live_grep, the `ui-select` dropdown, etc), since none of them override `initial_mode` on their own.
- `mini.files` (from the already-installed `mini.nvim`, so no new plugin): `<leader>e` opens a floating file explorer at the current file's directory, with that file pre-selected — falls back to cwd from an unnamed/non-file buffer. It's a normal editable buffer: rename a line to rename the file, `dd` to delete, `:w` to apply the changes. Replaces netrw's `:Ex`/`:Explore` as the everyday file browser (netrw itself is untouched, still there if you want it).
- `lua/custom/snippets/isml/isml.json`: ISML tag snippets (`isif`, `isloop`, `isset`, etc) loaded via LuaSnip's VS Code-format loader — Emmet-style completion for SFCC's own tags, which Emmet doesn't know about. See [sfcc.md](sfcc.md).
- `after/queries/html/highlights.scm`: recolors ISML tag names (`isif`, `isloop`, etc) as `@keyword` instead of plain `@tag`, so they read as SFCC's own control-flow tags rather than markup. See [sfcc.md](sfcc.md).
- `lua/custom/isml-expr-highlight.lua`: real JavaScript syntax highlighting for ISML's embedded `${...}` script expressions, wherever they appear (attribute values, mixed with literal text, or standalone page text) — scoped to `.isml` files only. See [sfcc.md](sfcc.md).
- `lua/custom/isml-comment-highlight.lua`: renders `<iscomment>...</iscomment>` blocks (ISML's own block-comment tag) as real dimmed/italic comments, tags and contents included — scoped to `.isml` files only. See [sfcc.md](sfcc.md).
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
- `lua/custom/plugins/accelerated-jk.lua`: `accelerated-jk.nvim` — holding `j`/`k` moves faster the longer it's held (1 line/press for the first ~7 repeats, then 2, 3, 4... per the plugin's default `acceleration_table`), instead of a flat one-line-per-repeat the whole time.
- `lua/custom/plugins/toggleterm.lua`: `toggleterm.nvim` — `<leader>tt` toggles a floating terminal for one-off shell commands (`git pull`, running a dev server, `lazygit`, etc) without leaving Neovim. It's persistent: toggling it away and back keeps scrollback and any running process. Prefix with a count for additional independent terminals (`2<leader>tt`) — each keeps its own buffer/scrollback/process, though with a floating layout only one is ever visible on screen at once (switching to another just hides the previous one's window, it doesn't kill it).
- Unsaved changes are hard to miss: `mini.statusline`'s `[+]` flag is recolored (bold, matches `DiagnosticError`) instead of blending into the filename's color, and `lua/custom/winbar.lua` adds a winbar showing a bold "● unsaved" marker when the buffer is modified — visible right above the code, not just off in the statusline.
- `lua/custom/plugins/navic.lua`: `nvim-navic` — LSP breadcrumbs (e.g. `Basket > calculateTotal`) for the cursor's current context, shown in the winbar (`lua/custom/winbar.lua`, alongside the unsaved marker above). Works fully for any language whose LSP supports `documentSymbol` (JS/TS via `ts_ls`, Lua via `lua_ls`, etc); for `.isml` files it only gets element-nesting breadcrumbs from the `html` LSP (no function names, since ISML/HTML has none), and doesn't see into `<isscript>`/`${...}` at all — same blind spot as the base html grammar in [sfcc.md](sfcc.md).
- The winbar is styled as powerline segments (solid color pill + arrow, matching tmux's `status-position top` bar directly above it) instead of plain text, so it reads as a continuation of that bar rather than looking like unstyled text dropped in below it. Colors resolve at runtime from the active colorscheme (`Normal`, `MiniStatuslineModeNormal`, `DiagnosticError`) rather than being hardcoded — blue in particular is read from `MiniStatuslineModeNormal`'s bg (tokyonight's own blue) instead of a second hardcoded copy of the tmux theme's color, specifically so this and the statusline/tmux blue can't silently drift apart again the way an earlier hardcoded copy here did.
- `mini.statusline`'s filename section shows the filename first and the full, dimmed directory second (e.g. `main.js  cartridges/app_pcrs/cartridge/client/default/js`), instead of the default `%f`/`%F` — same "filename first" idea as the Telescope `path_display` setting below, so a deep cartridge path never buries the filename. Deliberately doesn't lean on the statusline's own overflow truncation for this, since that truncates from the *left* of whatever follows mini's `%<` marker — with a long path that eats into the filename first, not the directory. On genuinely narrow windows (below the section's `trunc_width`) the directory is dropped outright rather than letting `%<` pick what to cut; on a merely-full-but-not-narrow window with a very deep path, `%<` can still fall back to trimming the filename — accepted tradeoff for always showing the full directory when there's room. The directory's dimmed text shares the *same* background as the filename (resolved from `MiniStatuslineFilename`, not just linked to `Comment`, which has none) so the two read as one continuous pill instead of a visibly different background starting partway through.
- `mini.statusline` cleanup: the diagnostics section (`Diag H9` — the standard Neovim E/W/I/H severity notation) and the LSP section (`LSP +`, one anonymous `+` per attached server) are both dropped entirely (`<leader>sd` covers actually wanting to look at diagnostics); the git section drops the `Git` text label (mini's fallback when there's no nerd font for an icon) since the branch name alone is enough; the diff section is hidden entirely when there's nothing to show instead of a bare, easy-to-misread `-` (still shows `+added ~changed -deleted` once there's an actual diff).
- The statusline's segments are joined with powerline arrows (same U+E0B0/U+E0B2 glyphs and blue as the tmux bar above it and the winbar below — see [tmux.md](tmux.md)) instead of colors changing abruptly: right-pointing between the left-aligned segments (mode → git/diff → filename), left-pointing between the right-aligned ones (filetype → location), each cluster capped with an arrow into/out of the plain `StatusLine` background. Colors are resolved once (and on `ColorScheme`) rather than per-redraw, since only the mode segment's color actually varies frame to frame.
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
| `<leader>e` | File explorer (mini.files) at the current file's location |
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
| `<leader>tt` | Toggle floating terminal — prefix with a count for another (`2<leader>tt`) |

**Commands (typed, not keymaps)**
| Command | Use |
|---|---|
| `:Lazy` | Plugin manager status/updates |
| `:Mason` | Manage LSP servers/formatters |
| `:checkhealth` | Diagnose setup problems |
| `:LspInfo` | LSP attached to current buffer |
| `:e path/to/file` | Create/open a new file |
| `:Explore` (or `:Ex`) | Open netrw's file explorer — still available, but `<leader>e` (mini.files) is the everyday one now, see below |

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
