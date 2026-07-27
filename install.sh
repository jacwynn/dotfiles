#!/usr/bin/env bash
# Bootstraps this dotfiles repo on a fresh machine: symlinks configs into
# place and installs the system-level tools they depend on. Safe to re-run.
#
# GETTING THIS REPO ONTO A NEW MACHINE FIRST (this script can't do this part --
# it lives inside the repo, so the repo has to exist locally before it can run):
#
#   This repo (github.com/jacwynn/dotfiles) is public, so the simplest option
#   needs zero credential setup:
#     git clone https://github.com/jacwynn/dotfiles.git ~/dotfiles
#
#   A plain folder/zip download (GitHub's "Download ZIP" button) also works for
#   just reading the files, but skip it -- it throws away git history, so you'd
#   have no way to `git pull` future updates onto that machine. The HTTPS clone
#   above is just as easy and stays a real, updatable repo.
#
#   HTTPS clone above only lets you *pull*. If you also want to *push* changes
#   from this machine back to GitHub (e.g. editing nvim config while working
#   from it), you need one of:
#     - SSH:  generate a key, add it to GitHub, then use the SSH remote:
#         ssh-keygen -t ed25519 -C "your_email@example.com"
#         eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519
#         cat ~/.ssh/id_ed25519.pub   # paste into github.com/settings/keys
#         git remote set-url origin git@github.com:jacwynn/dotfiles.git
#         ssh -T git@github.com       # should greet you by username if it works
#     - HTTPS + token: `gh auth login` (GitHub CLI) is the easiest way to get
#       push access over HTTPS without managing SSH keys at all.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "== Platform check =="
if [ "$(uname -s)" != "Darwin" ]; then
  echo "This script is written for macOS (uses Homebrew + a Homebrew cask for fonts)."
  echo "It won't work as-is on Linux/Windows -- adapt the package-manager calls below first."
  exit 1
fi

echo
echo "== Git / GitHub push access =="
origin_url="$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null || echo "")"
echo "origin: ${origin_url:-<none>}"
if [ "${origin_url#git@}" != "$origin_url" ] || [ "${origin_url#ssh://}" != "$origin_url" ]; then
  # SSH remote -- verify the key is actually registered with GitHub.
  # NOTE: `ssh -T` always exits non-zero (no shell access granted) even on
  # successful auth, so capture its output first rather than piping straight
  # into grep -- with `pipefail` on, that would mask a real match.
  ssh_check_output="$(ssh -T git@github.com -o BatchMode=yes -o ConnectTimeout=5 2>&1 || true)"
  if echo "$ssh_check_output" | grep -q "successfully authenticated"; then
    echo "ok:      SSH auth to GitHub is working"
  else
    echo "SSH auth to GitHub isn't working yet -- you can pull, but pushing will fail."
    echo "See the comment block at the top of this script for setup steps."
  fi
elif [ "${origin_url#https://}" != "$origin_url" ]; then
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    echo "ok:      gh is authenticated (push over HTTPS should work)"
  else
    echo "HTTPS remote with no \`gh\` auth detected -- you can pull (repo is public), but"
    echo "pushing will prompt for credentials. Run \`gh auth login\`, or switch the remote"
    echo "to SSH (see the comment block at the top of this script)."
  fi
fi

echo
echo "== Xcode Command Line Tools =="
if xcode-select -p >/dev/null 2>&1; then
  echo "ok:      Command Line Tools already installed"
else
  echo "Command Line Tools not found -- triggering the install (opens a GUI dialog)."
  xcode-select --install
  echo "Finish that install, then re-run this script -- Homebrew and several build steps"
  echo "(LuaSnip, telescope-fzf-native) need a C compiler/make from the CLT to proceed."
  exit 1
fi

echo
echo "== Homebrew =="
if command -v brew >/dev/null 2>&1; then
  echo "ok:      Homebrew already installed"
else
  echo "Homebrew not found -- installing it (non-interactive)."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon installs to /opt/homebrew, Intel to /usr/local.
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  echo "Homebrew installed. Add \`eval \"\$(brew shellenv)\"\` to your shell profile if the"
  echo "installer didn't already do so, so \`brew\` is on PATH in new shells."
fi

link() {
  local src="$1" dest="$2"
  if [ -L "$dest" ] && [ "$dest" -ef "$src" ]; then
    echo "ok:      $dest -> $src"
    return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "skip:    $dest already exists and isn't the expected symlink (leaving it alone)"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "linked:  $dest -> $src"
}

echo "== Symlinking configs =="
link "$DOTFILES_DIR/nvim/.config/nvim" "$HOME/.config/nvim"
link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
link "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
# oh-my-zsh itself is managed by its own installer/updater, not this script.

echo
echo "== Installing system dependencies (Homebrew) =="

# NOTE on Neovim version: this config's LSP setup uses vim.lsp.config()/vim.lsp.enable(),
# which require Neovim 0.11+. `brew install neovim` gives you whatever the latest formula
# is (0.12.x as of this writing) -- that's fine, it's a superset of 0.11. There's no upper
# version ceiling to worry about; this config does not use vim.pack.
#
# Checked separately from the rest below because "already installed" isn't good enough
# here -- an existing pre-0.11 install (e.g. from before this repo required it) needs an
# upgrade, not a skip.
NVIM_MIN_VERSION="0.11.0"
if command -v nvim >/dev/null 2>&1; then
  nvim_version="$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  if [ "$(printf '%s\n' "$NVIM_MIN_VERSION" "$nvim_version" | sort -V | head -1)" = "$NVIM_MIN_VERSION" ]; then
    echo "ok:      neovim $nvim_version (>= $NVIM_MIN_VERSION required)"
  else
    echo "neovim $nvim_version is too old (need >= $NVIM_MIN_VERSION) -- upgrading."
    brew upgrade neovim || brew install neovim
  fi
else
  brew install neovim
fi

brew_formulae=(
  git
  ripgrep   # required by Telescope's live grep
  fd        # required by Telescope's file finder
  tree-sitter-cli # treesitter parser CLI (Homebrew split this from the `tree-sitter` library formula)
  tmux
)
for f in "${brew_formulae[@]}"; do
  if brew list --formula "$f" >/dev/null 2>&1; then
    echo "ok:      $f already installed"
  else
    brew install "$f"
  fi
done

echo
echo "== tmux plugin manager (TPM) =="
# ~/.tmux itself is NOT tracked in this repo -- it's just TPM's install location
# (hardcoded as such by .tmux.conf's `run '~/.tmux/plugins/tpm/tpm'` line), not a
# framework this config depends on.
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "ok:      tpm already installed"
else
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
echo "After this, start tmux and press <prefix> + I (capital i) once to have tpm"
echo "install the actual plugin list (vim-tmux-navigator, tmux-resurrect, etc)."

if ! brew list --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1; then
  echo "Installing a Nerd Font (JetBrains Mono) for icons in nvim-tree/telescope/statusline..."
  brew install --cask font-jetbrains-mono-nerd-font
else
  echo "ok:      JetBrains Mono Nerd Font already installed"
fi

echo
echo "== Node (for ts_ls / eslint / prettier) =="
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  echo "ok:      nvm already installed"
else
  echo "nvm not found -- installing it."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
# shellcheck disable=SC1091
[ -s "$HOME/.nvm/nvm.sh" ] && \. "$HOME/.nvm/nvm.sh"
if command -v nvm >/dev/null 2>&1; then
  # Check the persisted "default" alias rather than `nvm current`, which just
  # reports whatever's first on PATH right now and can be stale/misleading.
  if nvm alias default 2>/dev/null | grep -q '\->.*->' ; then
    echo "ok:      nvm default already set ($(nvm alias default))"
  else
    echo "Installing Node LTS as the nvm default..."
    nvm install --lts
    nvm alias default 'lts/*'
  fi
  # `nvm alias default` only persists the default for *future* shells (ones
  # that source nvm.sh and then run `nvm use default` themselves) -- it does
  # NOT switch the node/npm already resolved on PATH in *this* script. `nvm
  # use` does that. Needed before the SFCC debugger build step below, which
  # otherwise silently picks up whatever old node happened to be on PATH
  # already (hit this directly: --openssl-legacy-provider was rejected
  # because it landed on a pre-17 node that predates the flag entirely).
  nvm use default >/dev/null
fi

echo
echo "== SFCC debugger (Prophet debug adapter) =="
# Builds the same debug adapter the "Prophet Debugger" VS Code extension uses
# (https://github.com/SqrTT/prophet), so nvim-dap can attach to an SFCC
# sandbox the same way VS Code does. There's no published binary/npm package
# for this -- the only way to get it is building from source, which is what
# this does. Lives outside the dotfiles repo (~/.local/share) since it's a
# build artifact, not config, same reasoning as TPM/lazy.nvim's plugin dirs.
#
# NOTE: its webpack 4 toolchain predates Node 17's OpenSSL 3 upgrade, which
# removed the md4 hash algorithm webpack 4 depends on by default -- the build
# fails with ERR_OSSL_EVP_UNSUPPORTED without NODE_OPTIONS=--openssl-legacy-provider.
# Confirmed this actually builds successfully on Node 24 with that flag set.
PROPHET_DIR="$HOME/.local/share/prophet-debugger"
if [ -f "$PROPHET_DIR/dist/mockDebug.js" ]; then
  echo "ok:      prophet debug adapter already built"
elif command -v npm >/dev/null 2>&1; then
  echo "Building the prophet debug adapter from source (one-time, ~1 minute)..."
  rm -rf "$PROPHET_DIR"
  git clone --depth 1 https://github.com/SqrTT/prophet.git "$PROPHET_DIR"
  ( cd "$PROPHET_DIR" && NODE_OPTIONS=--openssl-legacy-provider npm install && NODE_OPTIONS=--openssl-legacy-provider npm run prepare )
  if [ -f "$PROPHET_DIR/dist/mockDebug.js" ]; then
    echo "ok:      built successfully"
  else
    echo "Build did not produce dist/mockDebug.js -- check the output above for errors."
  fi
else
  echo "npm not found (nvm/Node install above may have failed) -- skipping. Re-run this"
  echo "script once Node is available to build the SFCC debugger."
fi

echo
echo "== Reminder for SFCC/Demandware work =="
echo "nvim_dw_sync reads sandbox credentials from a per-project dw.json (NOT tracked in"
echo "this dotfiles repo). Create one in each SFCC project's root -- see the plugin's"
echo "README for the expected format."
echo
echo "The SFCC debugger (Prophet adapter, see above) also reads dw.json, and additionally"
echo "requires it to be strictly valid JSON -- if you've left old sandbox configs"
echo "commented out in that file (// {...} blocks), remove them; a strict JSON parser"
echo "(used here, and by the standalone Prophet VS Code extension too) will reject the"
echo "whole file if anything follows the first closing brace."

echo
echo "Done. Set your terminal's font to the installed Nerd Font, then open nvim to let"
echo "lazy.nvim finish installing plugins (:Lazy) and Mason install LSP servers (:Mason)."
