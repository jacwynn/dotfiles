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
| `Alt-c` | Switch to workspace `C` (Ghostty) |
| `Alt-x` | Switch to workspace `X` (Chrome) |

`Alt-c`/`Alt-x` are paired with `[[on-window-detected]]` rules (matched by `app-id`) that auto-move Ghostty/Chrome to their named workspace the moment either opens a new window — so the keys land on the right app even before it's running yet, not just once it's already there.

**Caveat:** the auto-move rule fires per new window, not continuously — an existing window already sitting in another workspace (e.g. a browser window placed side-by-side with another app in workspace 2) is left alone. But a *new* Chrome window (`Cmd-N`, "open in new window", etc.) gets pulled into workspace `X` regardless of intent, since the rule can't distinguish "a new testing window I want to keep next to something else" from any other new Chrome window. If that happens and you wanted it elsewhere, `Alt-Shift-<workspace number>` immediately sends the focused window back to where you actually wanted it. Using a new *tab* instead of a new *window* sidesteps the rule entirely, if that works for what you're doing.

**Config**
| Key | Action |
|---|---|
| `Alt-Shift-r` | Reload `~/.aerospace.toml` without restarting AeroSpace |
