# Herdr

Terminal workspace manager for AI coding agents — tabs, splits, and a sidebar of agent panes, in the terminal (the TUI, not the `herdr-app` GUI cask — see [setup.md](setup.md)).

Config lives at `~/.config/herdr/config.toml` and `~/.config/herdr-app/settings.json`, both tracked in this repo and symlinked in by `install.sh` (`force_link`, not the cautious `link` — Herdr scaffolds its own default `config.toml` the first time it's ever launched, which would otherwise block a plain symlink from ever taking effect). After editing `config.toml` directly, `herdr server reload-config` applies it without restarting.

`herdr --default-config` prints the full default config with every available key and its default binding commented out — the actual reference for what's configurable, rather than guessing from the docs site.

**Prefix**: `ctrl+space` (not the default `ctrl+b`) — chosen to match tmux's own prefix in this setup (see [tmux.md](tmux.md)), so the two don't fight over muscle memory.

**Pane navigation**: bound directly to `ctrl+h/j/k/l` (`focus_pane_left/down/up/right`) rather than requiring the prefix first (`prefix+h/j/k/l` is still Herdr's own default). This is a direct, unprefixed terminal-mode shortcut — it intercepts those keys globally, in every pane, which deliberately conflicts with `vim-tmux-navigator`'s own `Ctrl+h/j/k/l` nvim-split-navigation (see [neovim.md](neovim.md)/[tmux.md](tmux.md)) and with `Ctrl+h`-as-backspace in any shell that relies on it. Accepted tradeoff: splitting is done via Herdr's own commands now, not nvim's `<C-w>v`/`<C-w>s`.

**Splitting**: `split_vertical` rebound from Herdr's default `prefix+v` to `prefix+|`, matching tmux's own `C-space |` (see [tmux.md](tmux.md)) instead of the two tools disagreeing on which key means "vertical." `split_horizontal` already defaulted to `prefix+minus`, same as tmux's `C-space -`, so it's set explicitly here just for the same documented-not-hidden-default reason as the line above it.
