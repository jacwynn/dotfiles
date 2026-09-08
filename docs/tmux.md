# Tmux

Prefix is remapped to **`C-space`** (not the default `C-b`). Plugins via TPM: `vim-tmux-navigator`, `tmux-resurrect`, `tmux-continuum`.

`focus-events on` is set so terminal focus events are forwarded into panes — this is required for Neovim's `FocusGained` autocmd to fire when switching tmux panes (used to detect files changed outside Neovim; see [neovim.md](neovim.md)). Without it, tmux swallows focus events and `FocusGained` never fires no matter what Neovim itself is configured to do.

**Status bar**: hand-written (no theme plugin — `tmux-themepack` was used here previously, removed), styled after [craftzdog/dotfiles](https://github.com/craftzdog/dotfiles)' tmux config: solid-color "pill" chips with rounded end-caps, recolored to tokyonight-night instead of their solarized palette. Left side: session name (bright chip) chained directly into username (muted chip). Right side: empty — it used to show the hostname as a single bright chip, dropped since it wasn't serving any real purpose. Window list: right-justified (`status-justify right`) so it now sits flush against the right edge instead of centered, since there's nothing in `status-right` left for it to make room for. Every window (active or not) gets its own number badge — a small muted-grey (`#24283b`, darkened from an earlier `#414868` once it started looking off against the orange accent) pill around `#I`, chained directly (no gap) into a name chip using the same flat color-switch technique as the session-name → username seam. The name chip's color is what signals focus: the bright accent (matching the session-name chip) for the current window, a subtler muted grey (`#292e42`) for every other one.

Windows themselves snap directly together with no separator at all — each window's format unconditionally re-asserts its own badge color the instant it starts, immediately overwriting whatever the previous window left behind, so consecutive windows never need an explicit connector between them. The only caps that remain are on the two true outer edges of the whole cluster (entering from open space before the first window, exiting after the last), gated by tmux's own `#{window_start_flag}`/`#{window_end_flag}` format variables ("1 if this window has the lowest/highest index") — every window in between gets neither. One real gotcha hit building this: a combined `#[fg=X,bg=Y]` style block breaks when placed inside a `#{?cond,...}` conditional, because the comma inside the brackets gets parsed as the conditional's own argument separator — confirmed by testing, not assumed. The fix is splitting it into separate `#[fg=X]#[bg=Y]` blocks (each with no internal comma) specifically for anything that needs to live inside a conditional.

Every bright chip uses `#ff9e64` (tokyonight's orange) as its own accent — deliberately *not* the `#7aa2f7` blue Neovim's winbar/statusline and the OmniWM border all share. Matching that blue exactly was tried first, but with tmux's bar sitting directly below Neovim's own statusline (see `status-position` above), identical colors made the two genuinely hard to tell apart at a glance. Tokyonight's purple (`#bb9af7`) was tried next — still too close in temperature/register to the blue to feel distinct. A warm accent against that cool blue reads as clearly separate at a glance, without breaking the overall color scheme; `#1a1b26`/`#292e42`/`#c0caf5` (backgrounds and foreground) are unchanged and still shared with Neovim. Needs `set -as terminal-features ",*:RGB"` (also set) for the raw hex colors to render as true 24-bit color rather than getting rounded to the nearest of the 256-color palette `default-terminal screen-256color` would otherwise cap them to.

The rounded end-caps (`U+E0B6`/`U+E0B4`, Nerd Font "Powerline Extra Symbols") are the *same glyph family* that caused unresolved rendering glitches trying this exact look for Neovim's `bufferline.nvim` tabs (see [neovim.md](neovim.md)) — abandoned there for a plain-arrow separator instead. Works here, unlike there, likely because tmux's status bar is a plain terminal row rendered directly by the terminal, not routed through Neovim's own internal tabline layout. The leftmost chip (session name) and the hostname chip deliberately have no end-cap on the side touching the screen edge — only inward-facing/between-chip transitions are rounded, so the bar's outer edges stay flush against the terminal boundary instead of leaving a small gap. The session-name → username seam is a flat, direct color switch with no glyph at all — a round cap there put a visible bump between two chips meant to read as one continuous unit, rather than two separate ones. The trailing edge, where the username chip exits into open space before the window list, keeps its round cap, since that boundary *should* read as a distinct edge — same idea for the hostname chip and the window list. `clock-mode-style`/`clock-mode-colour` (tmux's full-screen clock via `prefix + t`) are set directly rather than through a theme plugin's variable, unrelated to the glyph question — the status bar itself no longer shows a clock at all (time/date chips were tried and then dropped for simplicity).

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
