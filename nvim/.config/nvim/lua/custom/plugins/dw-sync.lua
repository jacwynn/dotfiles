-- SFCC/Demandware cartridge upload via Telescope.
--
-- Known upstream bugs (from the plugin's own README, unresolved as of the
-- last commit in June 2024 -- not something fixable from this config):
--   1. "Clean Project and Upload All" can fail partway through. If it
--      misbehaves, run "Clean Project" and "Upload Cartridges" as two
--      separate steps instead.
--   2. The cartridge list is only scanned once per session. If you add a
--      new cartridge to cwd after enabling upload, re-run "Upload Cartridges"
--      to pick it up -- there's no "refresh" action yet.
return {
  '3mpee3mpee/nvim_dw_sync',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    require('telescope').load_extension 'nvim_dw_sync'
    require('nvim_dw_sync').setup {}
  end,
  keys = {
    {
      '<leader>ds',
      ':Telescope nvim_dw_sync open_telescope<CR>',
      desc = 'DW Sync open telescope',
    },
  },
}
