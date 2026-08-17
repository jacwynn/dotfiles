# Tmux

Prefix is remapped to **`C-space`** (not the default `C-b`). Plugins via TPM: `vim-tmux-navigator`, `tmux-themepack`, `tmux-resurrect`, `tmux-continuum`.

`focus-events on` is set so terminal focus events are forwarded into panes — this is required for Neovim's `FocusGained` autocmd to fire when switching tmux panes (used to detect files changed outside Neovim; see [neovim.md](neovim.md)). Without it, tmux swallows focus events and `FocusGained` never fires no matter what Neovim itself is configured to do.

`tmux-themepack`'s `powerline/default/cyan` theme has its main blue (`@powerline-color-main-1`) overridden to `#7aa2f7` — tokyonight-night's own blue, the same shade Neovim's statusline uses for its Normal-mode indicator (see [neovim.md](neovim.md)) — so the tmux status bar and Neovim's winbar/statusline read as one continuous color scheme instead of two different blues stacked on top of each other. Needs `set -as terminal-features ",*:RGB"` (also set) for the raw hex color to render as true 24-bit color rather than getting rounded to the nearest of the 256-color palette `default-terminal screen-256color` would otherwise cap it to.

`vim-tmux-navigator` has two halves that both need to be present for seamless `C-h/j/k/l` navigation across both tmux panes and nvim splits:
- **tmux-side**: installed via TPM (`~/.tmux/plugins/vim-tmux-navigator`). If pane navigation does nothing at all (all four directions), TPM cloning itself (which `install.sh` does) is not the same as installing the plugins it manages — start tmux and press `<prefix> + I` (capital I) to have TPM actually fetch it.
- **nvim-side**: installed as a regular nvim plugin (`christoomey/vim-tmux-navigator` in `init.lua`). If navigation *into* an nvim pane works but you can't navigate back *out* of it, this half is missing or nvim's own `<C-w><C-h>`-style maps are shadowing it — nvim's plain window-nav keymaps only move within nvim's own splits and don't know how to hand off back to tmux at a split boundary.

**Windows**
| Key | Action |
|---|---|
| `C-space c` | New window |
| `C-space n` | Next window |
| `C-space w` | Interactive list of all windows |
| `C-space <number>` | Jump to window N (e.g. `C-space 2`) |
| `C-space ,` | Rename current window |
| `C-space &` | Kill current window |
| `C-space C-space` | Jump to last active window (custom — double-tap prefix) |

Note: the tmux default `C-space p` (previous window) is **not** available here — `p` is rebound to paste-buffer (see Copy mode below). Use `C-space w` or a window number instead.

**Panes**
| Key | Action |
|---|---|
| `C-space \|` | Split pane vertically (side by side) — custom |
| `C-space -` | Split pane horizontally (stacked) — custom |
| `C-h` / `C-j` / `C-k` / `C-l` | Move between panes — **no prefix needed**. Also moves between nvim splits with the same keys, including handing back off to tmux at a split boundary (both halves of vim-tmux-navigator — tmux-side and nvim-side — required, see note above) |
| `C-space h/j/k/l` | Resize active pane (repeatable — keep tapping within the timeout) |
| `C-space m` | Toggle pane zoom (fullscreen) — custom |
| `C-space x` | Kill current pane |

**Copy mode / misc**
| Key | Action |
|---|---|
| `C-space [` | Enter copy mode |
| `v` (in copy mode) | Begin selection — custom, vi-style |
| `y` (in copy mode) | Copy selection — custom |
| `C-space p` | Paste buffer — custom (not the tmux default previous-window) |
| `C-space r` | Reload `~/.tmux.conf` — custom |
| `C-k` | Clear scrollback history — custom, no prefix |
