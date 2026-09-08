# OmniWM

[OmniWM](https://omniwm.app) is a free, open-source tiling window manager for Apple Silicon Macs — Niri-style scrolling columns and Hyprland-style dwindle (BSP) tiling, developer-signed and notarized. Replaced AeroSpace as the window manager actually in daily use (AeroSpace is kept installed as a fallback — see [aerospace.md](aerospace.md) — but its config isn't the active one).

Like AeroSpace, it operates one level above tmux: OmniWM tiles whole macOS app windows, tmux keeps handling panes *within* the terminal window. No overlap by design.

Config lives at `~/.config/omniwm/settings.toml`, tracked and symlinked in from this repo (see [setup.md](setup.md)) — but it's also the file OmniWM's own Settings app rewrites directly when you change things through its UI (workspace list, borders, workspace bar, etc). Editing it by hand and using the Settings app are both legitimate; either way the file in this repo is the one that ends up live.

**Layout modes**: each workspace is independently either `niri` (windows live in columns in an infinite horizontal strip — new windows add a column rather than shrinking existing ones, navigate by scrolling) or `dwindle` (i3/AeroSpace-style binary space partitioning — the screen is always fully tiled, new windows split whatever's focused). `Option+Shift+D` toggles the current workspace between the two on the fly, so it's easy to compare them side by side rather than committing to one.

Layout is a per-*workspace* setting, not per-monitor — there's no config that forces "this monitor always uses dwindle" regardless of which workspace is showing (`monitorDwindleOverrides`/`monitorNiriOverrides` only tune each layout's own behavior — split ratios, gap sizes — not which layout gets picked). Workspaces 6/7 (the secondary/vertical monitor) are left on `niri` like everything else — switch a given workspace to `dwindle` manually with `Option+Shift+D` if niri's columns don't suit it in the moment.

**Focus / move** (customized to vim keys — the defaults are `Option+Arrow`)
| Key | Action |
|---|---|
| `Option-h/j/k/l` | Focus the window left/down/up/right |
| `Option-Shift-h/j/k/l` | Move the focused window left/down/up/right — moving into an occupied position swaps the two windows |

**Layout**
| Key | Action |
|---|---|
| `Option-Shift-D` | Toggle the current workspace between niri/dwindle layout |
| `Option-Shift-B` | Balance sizes — resets all windows/columns on the workspace back to even proportions |
| `Option-Return` | Toggle fullscreen for the focused window |

**Other** (OmniWM defaults, unchanged)
| Key | Action |
|---|---|
| `Control-Option-Space` | Open the command palette |
| `Option-Shift-O` | Toggle overview (see every window on every workspace at once) |
| `Option-\`` | Toggle the built-in quake terminal |
| `Option-1` … `Option-9` | Switch to workspace 1-9 |
| `Option-Shift-1` … `Option-Shift-9` | Send the focused window to workspace 1-9 |

**Freed up for Raycast**: `Option-C`, `Option-X`, and `Control-Option-T/F/R/M` are deliberately left `Unassigned` in `settings.toml` — OmniWM claiming a global hotkey blocks any other app (Raycast included) from also binding it, so these were unassigned specifically to make room for Raycast shortcuts. `toggleColumnTabbed`, `expandContainerToAvailablePrimarySpan`, `resetWindowSecondarySpan`, and `openMenuAnywhere` (the actions that used to live on the `Control-Option-T/F/R/M` keys) aren't bound to anything else right now.

**In progress, not yet functional**: `[[appRules]]` entries exist to auto-route Ghostty/Chrome/Outlook/Teams/Notion to named workspaces `C`/`X`/`E`/`T`/`N` (mirroring AeroSpace's own scheme — see [aerospace.md](aerospace.md)), but OmniWM's workspaces only accept positive numeric IDs — there's no such thing as a workspace literally named "C". Getting this working means creating numbered workspaces through the Settings app (Workspaces page), giving each a Display Name of the intended letter, then pointing the `assignToWorkspace` values (and equivalent `Option-C`/`Option-X`/etc. hotkeys, via `switchWorkspaceSlot.N`) at the real numeric IDs OmniWM assigns. Until that's done, these rules just don't match anything.

**Per-monitor orientation**: OmniWM auto-detects each display's orientation (`omniwmctl query displays` shows it per-monitor) and adjusts niri's columns accordingly — a portrait/vertical monitor gets horizontal *rows* that scroll up/down instead of vertical columns that scroll left/right. `monitorOrientationOverrides` in `settings.toml` exists to force this manually if auto-detection ever gets it wrong for a specific display.

**Verifying changes**: `omniwmctl query <workspaces|rules|displays|active-workspace|...>` reads live state directly from the running app — useful for confirming a `settings.toml` edit actually took effect, since hotkey/rule changes hot-reload but workspace *list* changes need an OmniWM restart to pick up. Requires `general.ipcEnabled = true` (already set).
