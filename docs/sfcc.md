# SFCC / Demandware

Everything specific to working in SFCC cartridges. General Neovim setup lives in [neovim.md](neovim.md); the debugger specifically is in [debugging.md](debugging.md).

## `dw.json`

Sandbox credentials for a project live in a per-project `dw.json`, **never committed to this repo**. Create one in each SFCC project's root — see the [nvim_dw_sync README](https://github.com/3mpee3mpee/nvim_dw_sync) for the expected format (`hostname`, `username`, `password`, `code-version`).

Both `nvim_dw_sync` and the Prophet debugger (see [debugging.md](debugging.md)) read this same file. The debugger's JSON parser is strict — if you've left an old sandbox config commented out below the active block (`// {...}`), that breaks parsing for a plain JSON parser. Remove trailing commented blocks.

## Cartridge detection

Cartridges are detected the same way everywhere in this config (dw-sync, format-on-save exclusion, editorconfig override, the debugger's cartridge auto-discovery): any directory containing a `.project` file whose content includes the marker string `com.demandware.studio.core.beehiveNature`, excluding anything under `node_modules`.

## `.isml` files

`lua/custom/filetype.lua` maps the `.isml` extension to the `html` filetype, so HTML tooling (the `html` LSP, Emmet, treesitter, etc — see [neovim.md](neovim.md)) works on SFCC templates without any extra configuration.

## ISML tag snippets

Emmet handles plain HTML tags, but ISML tags (`isif`, `isloop`, `isset`, `isprint`, etc) aren't HTML — Emmet has no idea they exist. `lua/custom/snippets/isml/isml.json` adds them as ordinary LuaSnip snippets instead: type a tag name (e.g. `isloop`) and accept it from the `blink.cmp` completion popup like any other suggestion (`<C-y>`), same as Emmet.

Adapted from the "Prophet Debugger" VS Code extension's own `snippets/snippets.json` ([SqrTT/prophet](https://github.com/SqrTT/prophet) — the same repo the SFCC debugger and the `dw-sync` upload fix are built from, see [debugging.md](debugging.md)): all 31 `is*` tag snippets, registered for the `html` filetype (since `.isml` maps there — see above) via `require('luasnip.loaders.from_vscode').lazy_load(...)` in `init.lua`'s LuaSnip config. Two snippets had bugs in the upstream source, fixed here: `iscontent` had an unclosed `${2|true,false|` choice placeholder, and `isredirect` wasn't self-closed. Verified headlessly that all snippets parse and expand into valid ISML markup.

Registering these under `html` rather than a dedicated `isml` filetype means they also show up as completion candidates in plain `.html` files — harmless in practice, since nothing in ordinary HTML starts with `is`.

## ISML syntax highlighting

`after/queries/html/highlights.scm` recolors `is*`-prefixed tag names (`isif`, `isloop`, `isset`, etc) as `@keyword` instead of the generic `@tag` every other HTML element gets, so ISML's own control-flow/directive tags visually stand out from plain markup — same idea as the [ISML tag snippets](#isml-tag-snippets) above, just for highlighting instead of completion, and scoped the same way (registered on `html`, since that's what `.isml` maps to).

This required a `;; extends` modeline as the file's first line. Without it, Neovim treats a query file found later on `'runtimepath'` as a full *replacement* for the base query of the same name, not an addition — so the file silently discarded every other html highlight rule (headings, attributes, tag delimiters, etc) instead of layering on top of them. `;; extends` tells Neovim to merge it in instead. (Caught by writing a headless test that dumped the merged query's capture list before and after adding the modeline — the `@keyword` capture was simply absent without it, and the true fix wasn't "why doesn't my match work" but "why isn't my file being merged at all.")

As a side effect of already-installed HTML tooling: embedded ISML script expressions (`condition="${pdict.foo}"`) get real JavaScript syntax highlighting for free, with no extra config. That specific `${...}` convention is exactly what `nvim-treesitter`'s bundled html injection query already handles (originally written for lit-html's template interpolation syntax, which happens to use the identical `${...}` delimiters) — no work was needed there beyond confirming it via the same headless test.

## Uploading cartridges (`nvim_dw_sync`)

`lua/custom/plugins/dw-sync.lua` wires up `nvim_dw_sync`, a Telescope-based cartridge upload picker. `<leader>ds` opens it (see [neovim.md](neovim.md)'s keymap table).

**"Upload Cartridges" / "Clean Project and Upload all" uses a patched upload, not the upstream one.** The upstream implementation PUTs every file individually over WebDAV with no `MKCOL` calls to create intermediate directories first — any file inside a directory that doesn't already exist on the sandbox fails with an HTTP 409, so upload only "sometimes" worked depending on whether the remote directory structure already happened to match (this is almost certainly what the plugin's own README means by "Clean Project and Upload All not working properly sometimes").

`dw-sync.lua` replaces `upload_cartridge` at runtime (monkey-patches the function on `nvim_dw_sync`'s own module table after it loads, so it survives plugin updates) with the same approach the real "Prophet Debugger" VS Code extension uses for its own cartridge upload (`src/server/WebDav.ts`'s `uploadCartridge`, same [SqrTT/prophet](https://github.com/SqrTT/prophet) repo the SFCC debugger is built from — see [debugging.md](debugging.md)): zip the cartridge locally → PUT the zip → `DELETE` the existing remote cartridge folder (clean slate) → `POST method=UNZIP` (SFCC's WebDAV server-side unzip extension — the same one Prophet and SFCC's own official tooling use) → delete the remote zip. One HTTP round-trip per cartridge instead of one per file, and no missing-directory 409s, since the whole tree is created atomically by the server-side unzip. `node_modules`, `.git`, and stray `.zip` files are excluded from the zip.

Verified against a local mock WebDAV server before shipping (no real sandbox available in that environment): confirmed the exact request sequence, and specifically confirmed a brand-new, deeply nested folder — the case that fails with the old file-by-file approach — is correctly created.

One known upstream bug remains, unrelated to the above (not something fixable from the config side): the cartridge list only populates once per session — after adding a new cartridge to a project, re-run "Upload Cartridges" to pick it up.

## Format-on-save is disabled in SFCC projects

Cartridge lint rules often conflict with prettier's defaults, so `conform.nvim`'s format-on-save is skipped entirely whenever a `dw.json` is found anywhere upward from the buffer's directory. Manual `<leader>f` still runs there if you want it for a specific file.

## Trailing whitespace is preserved in SFCC projects

Neovim's *built-in* editorconfig support (not `conform.nvim` — a separate, native feature) honors whatever a project's `.editorconfig` sets for `trim_trailing_whitespace`. SFCC cartridges commonly set this to `true` project-wide (shared with the whole team/other editors), but ISML templates can rely on trailing whitespace for output formatting.

`lua/custom/sfcc-editorconfig.lua` patches Neovim's editorconfig property handler to skip `trim_trailing_whitespace` specifically when a `dw.json` is found upward from the buffer — same detection used everywhere else above. The project's own `.editorconfig` is left untouched (it's shared, not this repo's to change); this is a Neovim-only override. Outside SFCC projects, trimming still works exactly as before.
