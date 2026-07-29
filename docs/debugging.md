# Debugging

`nvim-dap` + `nvim-dap-ui` — the closest nvim equivalent to VS Code's debugger + `launch.json`. It can even read an existing `.vscode/launch.json` directly via `require('dap.ext.vscode').load_launchjs()`, though this setup doesn't wire that in by default.

| Key | Action |
|---|---|
| `<F5>` | Start/continue debugging |
| `<F1>` / `<F2>` / `<F3>` | Step into / over / out |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Set a conditional breakpoint (prompts for the condition) |
| `<F7>` | Toggle the debug UI (also shows last session's output) |
| `<F8>` | Terminate the debug session |

**The debug UI** (`<F7>`, also opens automatically when a session starts) is a two-region layout:

*Left sidebar:*
| Panel | Shows |
|---|---|
| Scopes | Local/global variables in the current stack frame |
| Breakpoints | All breakpoints set, across files |
| Stacks | Call stack — inspect variables at any point in the call chain |
| Watches | Expressions you're tracking manually |

*Bottom:*
| Panel | Shows |
|---|---|
| REPL | Evaluate any expression in the current stopped context (type it, hit Enter) |
| Console | Raw adapter output (errors, logs) |

**Moving between panels without a mouse:** every panel is a regular Neovim split, so the normal `<C-h>`/`<C-j>`/`<C-k>`/`<C-l>` window-nav keys (wired to `vim-tmux-navigator` in this config — see [tmux.md](tmux.md)) move between them — `<C-h>` from the main editor into the sidebar, `<C-j>`/`<C-k>` to move up/down between Scopes/Breakpoints/Stacks/Watches, `<C-l>` back to the editor. `<C-w>w` / `<C-w>p` also cycle through windows if you'd rather not think about direction.

Keys inside any panel: `<CR>` expand a variable, `o` jump to source location, `w` add to Watches, `d` remove, `e` edit a watch expression, `r` send value to REPL.

Typical flow once stopped at a breakpoint: check **Scopes** for local variable values, move into the **REPL** panel to evaluate arbitrary expressions, step with `<F1>`/`<F2>`/`<F3>`/`<F5>`, move to the **Stacks** panel and press `<CR>` on a different frame to see the caller's variables, `w` on a Scopes variable to pin it in **Watches** so it's visible across steps.

## SFCC/Demandware debugging

`dap.adapters.prophet` in `dap.lua`: attaches to a sandbox the same way the "Prophet Debugger" VS Code extension does — same debug adapter binary, in fact (built from [SqrTT/prophet](https://github.com/SqrTT/prophet); `install.sh` builds it into `~/.local/share/prophet-debugger`, since there's no published binary or npm package for it). Reads `dw.json` for sandbox credentials (see [sfcc.md](sfcc.md)) and auto-detects cartridge folders (any directory containing a `.project` file with the SFCC marker string), so no extra per-project setup is needed beyond a valid `dw.json`.

Verified against a real sandbox:
- ✅ The adapter builds successfully from source (patches applied during the build, see below)
- ✅ Confirmed it's a genuine, protocol-compliant DAP server (sent it a raw `initialize` request directly, got a correct response back) — not something VS Code-specific
- ✅ The full config/cartridge-discovery handshake (`prophet.getdebugger.config` → `DebuggerConfig` custom request) works end-to-end, both against synthetic test data and a live sandbox — connects successfully, "waiting for breakpoint hit..." confirmed
- ✅ **Breakpoint-hit detection fixed and confirmed working end-to-end against a live sandbox** — see root cause below.
- ⚠️ **Your `dw.json` files need to be strictly valid JSON**: if you've left old sandbox configs commented out (`// {...}`) after the active block, that breaks any strict JSON parser (this one, and the real Prophet extension too) — remove trailing commented blocks.

**Root cause, found via `nvim-dap`'s TRACE logging + a diagnostic patch that surfaced the actual redirect `Location` header against a real sandbox:** `Connection.ts` builds the HTTP request's `path` as `options.baseUrl + options.uri`. Two bugs were stacked here:
1. `baseUrl` is a full absolute URL (scheme+host+path) — Node's `path` option should never contain that when `hostname` is also set separately (it is). Fixing only this didn't resolve the real failure (confirmed: rebuilt, byte offsets in the error shifted as expected showing the new code ran, but the redirect persisted).
2. `baseUrl` ends in `/` and every `uri` value (e.g. `/threads`) starts with `/`, so concatenation produces a double slash (`.../v2_0//threads`). The redirect's actual `Location` header, captured directly from a real sandbox response, confirmed this exactly: it pointed to the identical path with a single slash instead of two — a CDN/edge layer normalizing the malformed path.

Both are now fixed together (`install.sh`'s build step, see the comment there for the exact patch) — verified end-to-end against a live sandbox: breakpoints hit, and the DebuggerConfig handshake succeeds.
