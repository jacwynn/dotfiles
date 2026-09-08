-- Winbar: LSP breadcrumbs for the cursor's current context (nvim-navic --
-- see lua/custom/plugins/navic.lua), e.g. "MyClass > myMethod". The filename
-- itself isn't repeated here -- mini.statusline already shows it
-- filename-first, so it'd just be noise.
--
-- No longer shows an "unsaved" marker -- bufferline.nvim's own modified dot
-- on the tab itself (see lua/custom/plugins/bufferline.lua) already covers
-- that, right at the point you'd look to check which file is open, so a
-- second marker down here was redundant.
--
-- Styled as a powerline segment (solid color pill + arrow transition,
-- U+E0B0) matching this setup's tmux status bar and mini.statusline (see
-- init.lua's mini.statusline config, and
-- ~/.tmux/plugins/tmux-themepack/powerline/default/cyan.tmuxtheme), so all
-- three read as one continuous color scheme rather than looking like plain
-- unstyled text dropped in among styled bars. (tmux's status bar itself
-- moved to status-position "bottom" once bufferline.nvim's tab strip took
-- over the top of the editor -- this winbar sits right below that tab
-- strip, not below tmux, but keeps the same powerline styling regardless
-- of which bar is physically adjacent to it.) Blue is resolved at runtime
-- (see below) rather than hardcoded -- from MiniStatuslineModeNormal's bg
-- (tokyonight's own blue, #7aa2f7, the exact shade tmux's
-- @powerline-color-main-1 is overridden to match in .tmux.conf -- keeping
-- this dynamic instead of a second hardcoded copy is what avoids the two
-- silently drifting apart again).
--
-- Only shown for normal, listed file buffers -- skipped for terminals,
-- pickers, the mini.files explorer, etc (anything with a non-empty
-- 'buftype', or an unlisted buffer) so it doesn't clutter special windows.
-- Deferred (not resolved right here): this module is required before
-- require('lazy').setup(...) even starts, so reading these highlight
-- groups at this point would grab Neovim's built-in defaults instead of
-- tokyonight's (and mini.statusline wouldn't even be loaded yet to define
-- MiniStatuslineModeNormal at all). vim.schedule runs after the whole
-- startup script (colorscheme and plugins included) finishes; the
-- ColorScheme autocmd keeps it correct on any later switch.
-- U+E0B0 (powerline "solid right arrow"), as an explicit UTF-8 byte escape
-- rather than the literal glyph -- the raw character silently failed to
-- survive being written to this file the first time around (verified by
-- grepping the saved file's bytes: the literal produced an empty string).
local ARROW = '\238\130\176'

local function set_winbar_hl()
  local normal_bg = vim.api.nvim_get_hl(0, { name = 'Normal' }).bg
  local blue = vim.api.nvim_get_hl(0, { name = 'MiniStatuslineModeNormal' }).bg

  -- Segment fill: bright bg, dark (the editor's own bg) text -- same trick
  -- the tmux theme uses for its bright segments.
  vim.api.nvim_set_hl(0, 'WinbarContext', { fg = normal_bg, bg = blue, bold = true })
  -- Arrow out of the segment back to the plain winbar background: the glyph
  -- takes the segment's color as its own foreground.
  vim.api.nvim_set_hl(0, 'WinbarContextArrow', { fg = blue, bg = normal_bg })
end
vim.api.nvim_create_autocmd(
  'ColorScheme',
  { group = vim.api.nvim_create_augroup('custom-winbar-hl', { clear = true }), callback = set_winbar_hl }
)
vim.schedule(set_winbar_hl)

_G.dotfiles_winbar_status = function()
  if vim.bo.buftype ~= '' or not vim.bo.buflisted then return '' end

  local ok, navic = pcall(require, 'nvim-navic')
  local context = (ok and navic.is_available()) and navic.get_location() or ''
  if context == '' then return '' end

  -- No leading plain-background space here (unlike a typical winbar/
  -- statusline section) -- the whole point is for the colored pill to
  -- start flush against the left edge, same as tmux's own segments.
  return '%#WinbarContext# ' .. context .. ' %#WinbarContextArrow#' .. ARROW .. '%*'
end

vim.o.winbar = "%{%v:lua.dotfiles_winbar_status()%}"
