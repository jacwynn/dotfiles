-- Winbar: LSP breadcrumbs for the cursor's current context (nvim-navic --
-- see lua/custom/plugins/navic.lua), e.g. "MyClass > myMethod", plus a bold
-- "unsaved" marker when the buffer has changes -- so an unsaved file is
-- impossible to miss even glancing at the top of the window. Complements
-- the recolored [+] flag in mini.statusline (see init.lua's mini.nvim
-- config): the statusline flag is easy to overlook in peripheral vision
-- since it's off to the side; this sits right above the code you're
-- looking at. The filename itself isn't repeated here -- mini.statusline
-- already shows it filename-first, so it'd just be noise.
--
-- Only shown for normal, listed file buffers -- skipped for terminals,
-- pickers, the mini.files explorer, etc (anything with a non-empty
-- 'buftype', or an unlisted buffer) so it doesn't clutter special windows.
-- Deferred (not resolved right here): this module is required before
-- require('lazy').setup(...) even starts, so reading 'DiagnosticError' at
-- this point would grab Neovim's built-in default instead of tokyonight's.
-- vim.schedule runs after the whole startup script (colorscheme included)
-- finishes; the ColorScheme autocmd keeps it correct on any later switch.
local function set_modified_hl()
  local diag_error_fg = vim.api.nvim_get_hl(0, { name = 'DiagnosticError' }).fg
  vim.api.nvim_set_hl(0, 'WinbarModified', { fg = diag_error_fg, bold = true })
end
vim.api.nvim_create_autocmd(
  'ColorScheme',
  { group = vim.api.nvim_create_augroup('custom-winbar-hl', { clear = true }), callback = set_modified_hl }
)
vim.schedule(set_modified_hl)

_G.dotfiles_winbar_status = function()
  if vim.bo.buftype ~= '' or not vim.bo.buflisted then return '' end

  local ok, navic = pcall(require, 'nvim-navic')
  local context = (ok and navic.is_available()) and navic.get_location() or ''

  local modified = vim.bo.modified and '%#WinbarModified#● unsaved%*' or ''

  if context == '' and modified == '' then return '' end
  if context == '' then return ' ' .. modified end
  if modified == '' then return ' ' .. context end
  return ' ' .. context .. '  ' .. modified
end

vim.o.winbar = "%{%v:lua.dotfiles_winbar_status()%}"
