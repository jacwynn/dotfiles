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
| `<leader><leader>` | Switch buffers (Telescope) |
| `<leader>/` | Fuzzy search current buffer |
| `<leader>j` | Flash: jump to a visible location (type 1-2 chars, press the label) |
| `<leader>s.` | Recent files |
| `<leader>sd` | Search diagnostics |
| `<leader>sh` | Search help |
| `<leader>sk` | Search keymaps |

**Tabs (bufferline)**
| Key | Action |
|---|---|
| `Shift-H` / `Shift-L` | Previous / next tab |
| `<leader>t1` .. `t9` | Jump straight to tab N by position |
| `<leader>bd` | Close current tab |

**File explorer (mini.files)**
| Key | Action |
|---|---|
| `<leader>e` | Open at the current file's directory (falls back to cwd) |
| Edit a line | Rename that file/directory |
| `dd` | Delete |
| New line with a name (`dir/` for a directory) | Create a file/directory, nested paths in one line |
| `=` | Synchronize — apply pending changes (confirmation dialog first; *not* `:w`) |

**Terminal**
| Key | Action |
|---|---|
| `<leader>tt` | Toggle a floating terminal (prefix with a count, e.g. `2<leader>tt`, for another independent one) |
| `<leader>gg` | Toggle lazygit, in its own dedicated terminal |

**Sessions (persistence.nvim)**
| Key | Action |
|---|---|
| `<leader>qs` | Restore session for this directory |
| `<leader>qS` | Pick a session to restore |
| `<leader>ql` | Restore the last session |
| `<leader>qd` | Don't save a session on exit |

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
| `<leader>gs` | Telescope git status — all changed files, live diff preview |
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

**Folding**
| Key | Action |
|---|---|
| `za` | Toggle fold under cursor |
| `zc` / `zo` | Close / open fold under cursor |
| `zM` / `zR` | Close all folds / open all folds |
| `zj` / `zk` | Jump to next / previous fold |
| `zA` | Toggle recursively |

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

## OmniWM — [omniwm.md](omniwm.md)

The window manager actually in daily use.

| Key | Action |
|---|---|
| `Option-h/j/k/l` | Focus window left/down/up/right |
| `Option-Shift-h/j/k/l` | Move focused window left/down/up/right (swaps with whatever's there) |
| `Control-Option-Shift-h/j/k/l` | Move focused window to the monitor left/down/up/right |
| `Option-Shift-D` | Toggle the current workspace's layout (niri ↔ dwindle) |
| `Option-Shift-B` | Balance sizes — reset all windows/columns to even proportions |
| `Option-Return` | Toggle fullscreen |
| `Option-1`..`9` | Switch to workspace 1-9 |
| `Option-Shift-1`..`9` | Send focused window to workspace 1-9 |
| `Control-Option-Space` | Open the command palette |
| `Option-Shift-O` | Toggle overview (every window, every workspace) |
| `Option-Grave` (backtick) | Toggle the built-in quake terminal |

## AeroSpace — [aerospace.md](aerospace.md)

**Kept installed as a fallback, not in daily use** — kept in sync with OmniWM's bindings where AeroSpace has an equivalent feature (`Alt` and `Option` are the same key).

| Key | Action |
|---|---|
| `Alt-h/j/k/l` | Focus window left/down/up/right |
| `Alt-Shift-h/j/k/l` | Move focused window left/down/up/right |
| `Alt-Ctrl-h/j/k/l` | Join focused window with its neighbor into one split container |
| `Alt-Minus` / `Alt-Equal` | Resize the focused window smaller/larger |
| `Alt-Shift-B` | Balance sizes — reset all windows to even proportions |
| `Alt-Ctrl-Shift-h/j/k/l` | Move focused window to the monitor left/down/up/right |
| `Alt-Enter` | Toggle fullscreen |
| `Alt-Shift-Space` | Toggle floating |
| `Alt-/` | Toggle tiling orientation |
| `Alt-,` | Accordion layout |
| `Alt-1`..`9` | Switch to workspace 1-9 |
| `Alt-Shift-1`..`9` | Send focused window to workspace 1-9 |
| `Alt-c` / `Alt-x` | Switch to workspace C (Ghostty) / X (Chrome), auto-assigned on window open |
| `Alt-e` / `Alt-t` / `Alt-n` | Switch to workspace E/T/N and launch/focus Outlook/Teams/Notion |
| `Alt-Shift-r` | Reload `~/.aerospace.toml` |
