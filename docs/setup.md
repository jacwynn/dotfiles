# Setup

## Layout

```
.zshrc                    -> ~/.zshrc
.tmux.conf                -> ~/.tmux.conf
.aerospace.toml           -> ~/.aerospace.toml
nvim/.config/nvim/         -> ~/.config/nvim
install.sh                 bootstrap script for a new machine
docs/                       one doc per feature/configuration (this file included)
```

oh-my-zsh itself (`~/.oh-my-zsh`) is not tracked here — it's a separate, self-updating install (its own git clone), managed by oh-my-zsh's own installer/updater rather than this repo.

Similarly, `~/.tmux` is not tracked here — `.tmux.conf` hardcodes TPM (the tmux plugin manager) to live at `~/.tmux/plugins/tpm`, so that directory is just TPM's install location, not a framework this config depends on. `install.sh` clones TPM there if it's missing.

## New machine setup

This repo is public, so getting it onto a new machine needs no credentials:

```bash
git clone https://github.com/jacwynn/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` is idempotent (safe to re-run) and:
- symlinks `.zshrc`, `.tmux.conf`, `.aerospace.toml`, and the nvim config into place
- installs Xcode Command Line Tools / Homebrew if missing
- installs `neovim`, `git`, `ripgrep`, `fd`, `tree-sitter-cli`, `tmux`, and a Nerd Font
- taps `nikitabobko/tap` and installs AeroSpace if missing (see [aerospace.md](aerospace.md))
- installs `nvm` + Node LTS if missing
- clones TPM (tmux plugin manager) if missing — after that, start tmux and press `<prefix> + I` once to install the actual plugin list (see [tmux.md](tmux.md))
- builds the SFCC debug adapter if `nvm` is available (see [sfcc.md](sfcc.md))
- checks whether SSH/`gh` push access to GitHub is actually working

Read the comment block at the top of `install.sh` for SSH key setup if you want to push from a new machine (a plain clone only needs to pull).

### If the machine's default GitHub account isn't jacwynn

The HTTPS clone above works regardless (public repo, no auth needed to pull). Push access needs a second SSH identity scoped just to this repo, via an SSH config host alias:

```bash
ssh-keygen -t ed25519 -C "jacwynn key" -f ~/.ssh/id_ed25519_jacwynn

# add to ~/.ssh/config:
Host github.com-jacwynn
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_jacwynn

# paste ~/.ssh/id_ed25519_jacwynn.pub into github.com/settings/keys (jacwynn's account)

git clone git@github.com-jacwynn:jacwynn/dotfiles.git ~/dotfiles
# or, if already cloned via HTTPS:
git remote set-url origin git@github.com-jacwynn:jacwynn/dotfiles.git
```

**SFCC/Demandware work:** sandbox credentials live in a per-project `dw.json`, never in this repo. See [sfcc.md](sfcc.md) for the expected format and everything else SFCC-specific in this config.
