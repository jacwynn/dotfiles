# AeroSpace

[AeroSpace](https://github.com/nikitabobko/AeroSpace) is an i3-like tiling window manager for macOS. It operates one level above tmux: AeroSpace tiles whole macOS app windows (terminal, browser, etc), while tmux keeps handling panes *within* the terminal window — no overlap between the two, by design. Every binding below is Alt-based specifically so nothing collides with tmux's `C-s` prefix or `vim-tmux-navigator`'s `C-h/j/k/l` pane/split navigation (see [tmux.md](tmux.md)).

Not in default `homebrew-cask` — it lives in the author's own tap (`nikitabobko/tap`), which `install.sh` taps automatically before installing it.

`start-at-login = false` in `.aerospace.toml` for now — flip it once you're happy with the keybindings and want it running every session. AeroSpace needs Accessibility permission to manage windows; macOS prompts for this the first time you launch it (System Settings → Privacy & Security → Accessibility).

**Windows / focus**
| Key | Action |
|---|---|
| `Alt-h/j/k/l` | Focus the window left/down/up/right |
| `Alt-Shift-h/j/k/l` | Move the focused window left/down/up/right |
| `Alt-Enter` | Toggle fullscreen for the focused window |
| `Alt-Shift-Space` | Toggle floating for the focused window |

**Layout**
| Key | Action |
|---|---|
| `Alt-/` | Toggle tiling orientation (horizontal/vertical) |
| `Alt-,` | Switch to accordion layout (stacked windows) |

**Workspaces**
| Key | Action |
|---|---|
| `Alt-1` … `Alt-9` | Switch to workspace 1-9 |
| `Alt-Shift-1` … `Alt-Shift-9` | Send the focused window to workspace 1-9 |

**Config**
| Key | Action |
|---|---|
| `Alt-Shift-r` | Reload `~/.aerospace.toml` without restarting AeroSpace |
