# Keybindings — full reference

Every keymap in this config in one place. For explanations/context behind any of these, see the linked doc per section.

## Neovim — [neovim.md](neovim.md)

Leader is `<space>`.

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

**LSP**
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

**Git (gitsigns)**
| Key | Action |
|---|---|
| `<leader>hb` | Blame current line (full popup) |
| `<leader>tb` | Toggle inline blame |
| `<leader>hp` | Preview hunk diff |
| `<leader>hs` / `<leader>hr` | Stage / reset hunk |
| `<leader>hS` / `<leader>hR` | Stage / reset whole buffer |
| `<leader>hd` / `<leader>hD` | Diff against index / last commit |
| `]c` / `[c` | Jump to next / previous change |

**Windows & buffers**
| Key | Action |
|---|---|
| `<C-h/j/k/l>` | Move between splits (and tmux panes) |
| `<C-w>v` / `<C-w>s` | Split vertically / horizontally |
| `<C-w>c` / `:q` | Close current split only |
| `<C-w>o` | Close every split except the current one |
| `<C-^>` | Jump to the alternate (previously edited) buffer |
| `<C-o>` / `<C-i>` | Back/forward through the jump list |
| `<leader>q` | Diagnostics to quickfix |
| `<Esc>` | Clear search highlight |
| `<leader>ds` | SFCC: DW Sync picker |

**Harpoon**
| Key | Action |
|---|---|
| `<leader>a` | Add current file to the harpoon list |
| `<C-e>` | Toggle the quick-menu |
| `<leader>1` .. `7` | Jump straight to marked file 1–7 |

**Debugging** — see [debugging.md](debugging.md)
| Key | Action |
|---|---|
| `<F5>` | Start/continue debugging |
| `<F1>` / `<F2>` / `<F3>` | Step into / over / out |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Set a conditional breakpoint |
| `<F7>` | Toggle the debug UI |
| `<F8>` | Terminate the debug session |
| `<C-h/j/k/l>` | Move between debug UI panels (they're regular splits) |
| `<CR>` / `o` / `w` / `d` / `e` / `r` | Expand / jump to source / add watch / remove / edit watch / send to REPL |

## Tmux — [tmux.md](tmux.md)

Prefix is `C-space`.

| Key | Action |
|---|---|
| `C-space c` | New window |
| `C-space n` | Next window |
| `C-space w` | Interactive list of all windows |
| `C-space <number>` | Jump to window N |
| `C-space ,` | Rename current window |
| `C-space &` | Kill current window |
| `C-space C-space` | Jump to last active window |
| `C-space \|` | Split pane vertically |
| `C-space -` | Split pane horizontally |
| `C-h/j/k/l` | Move between panes (no prefix) |
| `C-space h/j/k/l` | Resize active pane |
| `C-space m` | Toggle pane zoom |
| `C-space x` | Kill current pane |
| `C-space [` | Enter copy mode |
| `v` / `y` (copy mode) | Begin selection / copy selection |
| `C-space p` | Paste buffer |
| `C-space r` | Reload `~/.tmux.conf` |
| `C-k` | Clear scrollback history |

## AeroSpace — [aerospace.md](aerospace.md)

| Key | Action |
|---|---|
| `Alt-h/j/k/l` | Focus window left/down/up/right |
| `Alt-Shift-h/j/k/l` | Move focused window left/down/up/right |
| `Alt-Enter` | Toggle fullscreen |
| `Alt-Shift-Space` | Toggle floating |
| `Alt-/` | Toggle tiling orientation |
| `Alt-,` | Accordion layout |
| `Alt-1`..`9` | Switch to workspace 1-9 |
| `Alt-Shift-1`..`9` | Send focused window to workspace 1-9 |
| `Alt-c` / `Alt-b` | Switch to workspace C (Ghostty) / B (Chrome), auto-assigned on window open |
| `Alt-Shift-r` | Reload `~/.aerospace.toml` |
