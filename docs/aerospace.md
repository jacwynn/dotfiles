# AeroSpace

**Kept installed as a fallback, not the window manager in daily use** — see [omniwm.md](omniwm.md) for the one actually running. This doc (and `.aerospace.toml`) stay as-is in case of ever switching back — in particular, for any machine that can't run OmniWM at all (it needs a newer macOS than every machine has).

[AeroSpace](https://github.com/nikitabobko/AeroSpace) is an i3-like tiling window manager for macOS. It operates one level above tmux: AeroSpace tiles whole macOS app windows (terminal, browser, etc), while tmux keeps handling panes *within* the terminal window — no overlap between the two, by design. Every binding below is Alt-based specifically so nothing collides with tmux's prefix or `vim-tmux-navigator`'s `C-h/j/k/l` pane/split navigation (see [tmux.md](tmux.md)).

Not in default `homebrew-cask` — it lives in the author's own tap (`nikitabobko/tap`), which `install.sh` taps automatically before installing it.

`start-at-login = false` in `.aerospace.toml` for now — flip it once you're happy with the keybindings and want it running every session. AeroSpace needs Accessibility permission to manage windows; macOS prompts for this the first time you launch it (System Settings → Privacy & Security → Accessibility).

**Kept in sync with OmniWM where possible**: `Alt` and OmniWM's `Option` are the same physical key, and AeroSpace's `focus`/`move`/`fullscreen`/workspace-switch bindings already match OmniWM's `Option`-based ones exactly, so most muscle memory carries over between machines without any deliberate effort. `balance-sizes` and cross-monitor window movement were added here specifically to close the two gaps that did exist — see the tables below. Things OmniWM has with no AeroSpace equivalent at all (a command palette, an overview mode, a built-in quake terminal, a niri/dwindle-style layout toggle) simply have no counterpart here; AeroSpace's own layout model (tiling orientation, accordion) is a different-enough concept that forcing a 1:1 key mapping there would be misleading rather than helpful.

**Windows / focus**
| Key | Action |
|---|---|
| `Alt-h/j/k/l` | Focus the window left/down/up/right |
| `Alt-Shift-h/j/k/l` | Move the focused window left/down/up/right |
| `Alt-Enter` | Toggle fullscreen for the focused window |
| `Alt-Shift-Space` | Toggle floating for the focused window |
| `Alt-Ctrl-h/j/k/l` | Join the focused window with its neighbor into one shared split container (`split` is a no-op here — see the comment in `.aerospace.toml`, `enable-normalization-flatten-containers` defaults to true) |
| `Alt-Minus` / `Alt-Equal` | Resize the focused window smaller/larger (width or height, whichever the split orientation calls for) |
| `Alt-Shift-B` | Balance sizes — reset every window in the workspace back to even proportions |
| `Alt-Ctrl-Shift-h/j/k/l` | Move the focused window to the monitor left/down/up/right |

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
| `Alt-e` | Switch to workspace `E` and launch/focus Outlook |
| `Alt-t` | Switch to workspace `T` and launch/focus Teams |
| `Alt-n` | Switch to workspace `N` and launch/focus Notion |

`Alt-c`/`Alt-x` are paired with `[[on-window-detected]]` rules (matched by `app-id`) that auto-move Ghostty/Chrome to their named workspace the moment either opens a new window — so the keys land on the right app even before it's running yet, not just once it's already there. `Alt-e`/`Alt-t`/`Alt-n` do the same, plus actually launch the app (`open -a`) rather than assuming it's already running.

**Unverified bundle IDs**: Outlook and Teams aren't installed on the machine these were written on, so their `on-window-detected` rules are sourced from documentation/a disagreeing live lookup rather than a confirmed install — check with `aerospace list-apps` while the real app is running if the rule doesn't fire, and fix `.aerospace.toml` to match. Notion's `notion.id` bundle ID *is* confirmed (from a leftover `~/Library/Preferences/notion.id.plist` on that machine), just not currently installed there either.

**Caveat:** the auto-move rule fires per new window, not continuously — an existing window already sitting in another workspace (e.g. a browser window placed side-by-side with another app in workspace 2) is left alone. But a *new* Chrome window (`Cmd-N`, "open in new window", etc.) gets pulled into workspace `X` regardless of intent, since the rule can't distinguish "a new testing window I want to keep next to something else" from any other new Chrome window. If that happens and you wanted it elsewhere, `Alt-Shift-<workspace number>` immediately sends the focused window back to where you actually wanted it. Using a new *tab* instead of a new *window* sidesteps the rule entirely, if that works for what you're doing.

**Config**
| Key | Action |
|---|---|
| `Alt-Shift-r` | Reload `~/.aerospace.toml` without restarting AeroSpace |
