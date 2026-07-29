# SFCC / Demandware

Everything specific to working in SFCC cartridges. General Neovim setup lives in [neovim.md](neovim.md); the debugger specifically is in [debugging.md](debugging.md).

## `dw.json`

Sandbox credentials for a project live in a per-project `dw.json`, **never committed to this repo**. Create one in each SFCC project's root — see the [nvim_dw_sync README](https://github.com/3mpee3mpee/nvim_dw_sync) for the expected format (`hostname`, `username`, `password`, `code-version`).

Both `nvim_dw_sync` and the Prophet debugger (see [debugging.md](debugging.md)) read this same file. The debugger's JSON parser is strict — if you've left an old sandbox config commented out below the active block (`// {...}`), that breaks parsing for a plain JSON parser. Remove trailing commented blocks.

## Cartridge detection

Cartridges are detected the same way everywhere in this config (dw-sync, format-on-save exclusion, editorconfig override, the debugger's cartridge auto-discovery): any directory containing a `.project` file whose content includes the marker string `com.demandware.studio.core.beehiveNature`, excluding anything under `node_modules`.

## `.isml` files

`lua/custom/filetype.lua` maps the `.isml` extension to the `html` filetype, so HTML tooling (the `html` LSP, Emmet, treesitter, etc — see [neovim.md](neovim.md)) works on SFCC templates without any extra configuration.

## Uploading cartridges (`nvim_dw_sync`)

`lua/custom/plugins/dw-sync.lua` wires up `nvim_dw_sync`, a Telescope-based cartridge upload picker. `<leader>ds` opens it (see [neovim.md](neovim.md)'s keymap table).

Two known upstream bugs (documented in the comment in that file, not something fixable from the config side):
- "Clean Project" and "Upload All" can be flaky — if it misbehaves, prefer running "Clean Project" and "Upload Cartridges" as separate steps instead.
- The cartridge list only populates once per session — after adding a new cartridge to a project, re-run "Upload Cartridges" to pick it up.

## Format-on-save is disabled in SFCC projects

Cartridge lint rules often conflict with prettier's defaults, so `conform.nvim`'s format-on-save is skipped entirely whenever a `dw.json` is found anywhere upward from the buffer's directory. Manual `<leader>f` still runs there if you want it for a specific file.

## Trailing whitespace is preserved in SFCC projects

Neovim's *built-in* editorconfig support (not `conform.nvim` — a separate, native feature) honors whatever a project's `.editorconfig` sets for `trim_trailing_whitespace`. SFCC cartridges commonly set this to `true` project-wide (shared with the whole team/other editors), but ISML templates can rely on trailing whitespace for output formatting.

`lua/custom/sfcc-editorconfig.lua` patches Neovim's editorconfig property handler to skip `trim_trailing_whitespace` specifically when a `dw.json` is found upward from the buffer — same detection used everywhere else above. The project's own `.editorconfig` is left untouched (it's shared, not this repo's to change); this is a Neovim-only override. Outside SFCC projects, trimming still works exactly as before.
