-- SFCC/Demandware cartridges commonly have an .editorconfig with
-- trim_trailing_whitespace = true (shared with the whole team, other editors
-- included -- left untouched on purpose). ISML templates in particular often
-- rely on trailing whitespace/blank lines for output formatting, so silently
-- stripping it on save is undesirable specifically in these projects. Patching
-- Neovim's built-in editorconfig handler (not conform.nvim -- this trimming is
-- unrelated to autoformatting, it's a separate native feature) to skip
-- trim_trailing_whitespace whenever a dw.json is found upward from the buffer,
-- same detection used for format-on-save and the SFCC debugger.
local ec_ok, ec = pcall(require, 'editorconfig')
if ec_ok then
  local original_trim = ec.properties.trim_trailing_whitespace
  ec.properties.trim_trailing_whitespace = function(bufnr, val, opts)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname ~= '' then
      local dw_json = vim.fs.find('dw.json', { path = vim.fs.dirname(bufname), upward = true })[1]
      if dw_json then return end
    end
    return original_trim(bufnr, val, opts)
  end
end
