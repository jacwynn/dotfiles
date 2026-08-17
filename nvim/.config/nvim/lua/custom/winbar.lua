-- Winbar: LSP breadcrumbs for the cursor's current context (nvim-navic --
-- see lua/custom/plugins/navic.lua), e.g. "MyClass > myMethod", plus a bold
-- "unsaved" marker when the buffer has changes -- so an unsaved file is
-- impossible to miss even glancing at the top of the window. The filename
-- itself isn't repeated here -- mini.statusline already shows it
-- filename-first, so it'd just be noise.
--
-- Styled as powerline segments (solid color pill + arrow transition,
-- U+E0B0) matching this setup's tmux status bar and mini.statusline (see
-- init.lua's mini.statusline config, and
-- ~/.tmux/plugins/tmux-themepack/powerline/default/cyan.tmuxtheme), so the
-- winbar reads as a continuation of the bar directly above it (tmux's
-- status-position is "top") instead of looking like plain unstyled text
-- dropped in below it. Blue and red are both resolved at
-- runtime (see below) rather than hardcoded -- blue from
-- MiniStatuslineModeNormal's bg (tokyonight's own blue, #7aa2f7, the exact
-- shade tmux's @powerline-color-main-1 is overridden to match in
-- .tmux.conf -- keeping this dynamic instead of a second hardcoded copy is
-- what avoids the two silently drifting apart again), red from
-- DiagnosticError -- so both stay correct if the colorscheme ever changes.
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
  local diag_error_fg = vim.api.nvim_get_hl(0, { name = 'DiagnosticError' }).fg

  -- Segment fills: bright bg, dark (the editor's own bg) text -- same trick
  -- the tmux theme uses for its bright segments.
  vim.api.nvim_set_hl(0, 'WinbarContext', { fg = normal_bg, bg = blue, bold = true })
  vim.api.nvim_set_hl(0, 'WinbarModified', { fg = normal_bg, bg = diag_error_fg, bold = true })
  -- Arrow out of a segment back to the plain winbar background: the glyph
  -- takes the segment's color as its own foreground.
  vim.api.nvim_set_hl(0, 'WinbarContextArrow', { fg = blue, bg = normal_bg })
  vim.api.nvim_set_hl(0, 'WinbarModifiedArrow', { fg = diag_error_fg, bg = normal_bg })
  -- Arrow directly from the context segment into the modified segment,
  -- when both are shown back-to-back.
  vim.api.nvim_set_hl(0, 'WinbarContextToModified', { fg = blue, bg = diag_error_fg })
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
  local modified = vim.bo.modified

  if context == '' and not modified then return '' end

  -- No leading plain-background space here (unlike a typical winbar/
  -- statusline section) -- the whole point is for the colored pill to
  -- start flush against the left edge, same as tmux's own segments.
  local out = ''
  if context ~= '' then
    out = out .. '%#WinbarContext# ' .. context .. ' '
    out = out .. (modified and '%#WinbarContextToModified#' or '%#WinbarContextArrow#') .. ARROW
  end
  if modified then out = out .. '%#WinbarModified# ● unsaved %#WinbarModifiedArrow#' .. ARROW end

  return out .. '%*'
end

vim.o.winbar = "%{%v:lua.dotfiles_winbar_status()%}"
