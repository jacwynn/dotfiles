-- flash.nvim: press <leader>j, then type 1-2 characters -- every matching
-- spot visible on screen gets a jump label overlaid on it, press that label
-- to land there instantly. Faster than `/search<CR>` for short in-view hops,
-- and unlike `f`/`t` it isn't limited to the current line.
--
-- Bound to <leader>j instead of flash's own default 's'/'S' -- mini.surround
-- already claims bare 's' outright (mapped to <Nop> to skip a timeoutlen
-- delay on every sa/sd/sr press), so reusing 's' here would mean whichever
-- plugin's keymap wins outright overrides the other, not a graceful
-- coexistence.
return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {},
  keys = {
    {
      '<leader>j',
      mode = { 'n', 'x', 'o' },
      function() require('flash').jump() end,
      desc = '[J]ump to a visible location',
    },
  },
}
