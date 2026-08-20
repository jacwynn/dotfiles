-- fine-cmdline: replaces the plain bottom-line ':' command prompt with a
-- floating input box -- just that one piece, not the full noice.nvim-style
-- overhaul of messages/search/LSP progress (which would overlap with
-- fidget.nvim, already in use here). Trying this out to see how it feels
-- day-to-day, not committed to keeping it.
--
-- Only ':' itself is remapped, not ';' (this config's ':'-alias, see
-- init.lua's `vim.keymap.set('n', ';', ':', ...)`) -- that mapping is
-- noremap by default (vim.keymap.set's own default), so it inserts a
-- literal ':' keypress without re-triggering this new mapping on ':'.
-- That's left as-is deliberately: it means ';' still opens the plain
-- built-in cmdline no matter what, a free fallback if the floating one
-- ever gets in the way.
--
-- NOTE from the plugin's own README: it doesn't run inside real
-- command-line-mode, so features tied to that (live substitute preview,
-- etc.) don't work here -- fine for typing ordinary : commands, not a full
-- replacement for the built-in cmdline.
return {
  'VonHeikemen/fine-cmdline.nvim',
  dependencies = { 'MunifTanjim/nui.nvim' },
  config = function()
    require('fine-cmdline').setup {
      popup = {
        border = {
          style = 'rounded',
          text = { top = ' Cmdline ', top_align = 'center' },
        },
      },
    }
    vim.keymap.set('n', ':', '<cmd>FineCmdline<CR>', { desc = 'Open floating cmdline' })
  end,
}
