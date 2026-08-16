-- accelerated-jk: holding j/k moves faster the longer you hold it, instead
-- of a flat one-line-per-repeat the whole time.
return {
  'rainbowhxch/accelerated-jk.nvim',
  config = function()
    require('accelerated-jk').setup()
    vim.keymap.set('n', 'j', '<Plug>(accelerated_jk_j)', { desc = 'Down (accelerates when held)' })
    vim.keymap.set('n', 'k', '<Plug>(accelerated_jk_k)', { desc = 'Up (accelerates when held)' })
  end,
}
