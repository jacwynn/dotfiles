-- nvim-navic: LSP-based breadcrumbs (e.g. "MyClass > myMethod") for the
-- current cursor position, rendered in the winbar by lua/custom/winbar.lua.
--
-- Loaded eagerly (no lazy-loading trigger), deliberately: lsp.auto_attach
-- below registers navic's own LspAttach autocmd, which has to exist BEFORE
-- the first real LspAttach fires for whatever buffer opens first -- an
-- event-based lazy trigger (e.g. event = 'LspAttach') would race that same
-- event and could miss it. Navic is a single small file, so eager loading
-- costs nothing meaningful at startup.
return {
  'SmiteshP/nvim-navic',
  config = function()
    require('nvim-navic').setup {
      lsp = { auto_attach = true },
      -- Match the have_nerd_font pattern used elsewhere in this config --
      -- these icons are nerd-font glyphs, unrenderable without one.
      icons = { enabled = vim.g.have_nerd_font },
      highlight = true,
      separator = ' > ',
    }
  end,
}
