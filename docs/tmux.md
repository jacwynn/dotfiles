# Tmux

Prefix is remapped to **`C-s`** (not the default `C-b`). Plugins via TPM: `vim-tmux-navigator`, `tmux-themepack`, `tmux-resurrect`, `tmux-continuum`.

`focus-events on` is set so terminal focus events are forwarded into panes — this is required for Neovim's `FocusGained` autocmd to fire when switching tmux panes (used to detect files changed outside Neovim; see [neovim.md](neovim.md)). Without it, tmux swallows focus events and `FocusGained` never fires no matter what Neovim itself is configured to do.

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
