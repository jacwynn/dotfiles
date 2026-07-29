# dotfiles

Personal macOS dotfiles: zsh (oh-my-zsh) + Neovim + tmux + AeroSpace, symlinked into place via `install.sh`.

```
git clone https://github.com/jacwynn/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

## Documentation

| Doc | Covers |
|---|---|
| [docs/setup.md](docs/setup.md) | Repo layout, new machine setup, `install.sh`, GitHub push access from a second machine |
| [docs/neovim.md](docs/neovim.md) | Neovim customizations on top of kickstart.nvim, known quirks, commands, Harpoon |
| [docs/debugging.md](docs/debugging.md) | `nvim-dap` + `nvim-dap-ui`, including the SFCC/Demandware Prophet adapter |
| [docs/sfcc.md](docs/sfcc.md) | Everything SFCC/Demandware-specific: `dw.json`, cartridge detection, `nvim_dw_sync`, format-on-save and whitespace exceptions |
| [docs/tmux.md](docs/tmux.md) | tmux config and keybindings |
| [docs/aerospace.md](docs/aerospace.md) | AeroSpace tiling window manager |
| [docs/keybindings.md](docs/keybindings.md) | Every keybinding across all of the above, in one page |
