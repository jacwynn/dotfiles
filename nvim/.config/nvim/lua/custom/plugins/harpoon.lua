-- Harpoon: mark a small working set of files and jump straight to them,
-- instead of cycling through telescope buffers or :bnext/:bprev.
--
-- NOTE: harpoon's own README suggests <C-h> and <C-s> for jumping to marks 1
-- and 4. Neither works in this setup: <C-h> is already owned by
-- vim-tmux-navigator (moves to the tmux pane / nvim split on the left), and
-- <C-s> is the tmux prefix key -- tmux intercepts it before it ever reaches
-- nvim, so a mapping on it would simply never fire. Using <leader>1-4 instead.
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup()

    vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end, { desc = 'Harpoon: [a]dd file' })
    vim.keymap.set('n', '<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon: toggle quick menu' })

    for i = 1, 4 do
      vim.keymap.set('n', '<leader>' .. i, function() harpoon:list():select(i) end, { desc = 'Harpoon: jump to file ' .. i })
    end
  end,
}
