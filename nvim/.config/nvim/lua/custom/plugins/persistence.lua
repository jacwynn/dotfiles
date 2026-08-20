-- persistence.nvim: auto-saves the open buffers/window layout per project
-- directory (and git branch) in the background, restore with a keymap --
-- the Neovim-side equivalent of tmux-resurrect (see .tmux.conf). Never
-- restores automatically; you choose when.
--
-- <leader>q is already bound to diagnostics-to-quickfix (see init.lua). The
-- q* keymaps below are the plugin's own suggested convention (q for
-- "quit"/session, matching community docs) -- they coexist fine with the
-- existing single-key <leader>q, just adds a brief timeoutlen wait before
-- that one fires while Neovim checks whether more keys are coming.
return {
  'folke/persistence.nvim',
  event = 'BufReadPre',
  opts = {},
  keys = {
    { '<leader>qs', function() require('persistence').load() end, desc = '[Q]uit: restore [s]ession for this dir' },
    { '<leader>qS', function() require('persistence').select() end, desc = '[Q]uit: [S]elect a session to restore' },
    { '<leader>ql', function() require('persistence').load { last = true } end, desc = '[Q]uit: restore [l]ast session' },
    { '<leader>qd', function() require('persistence').stop() end, desc = "[Q]uit: [d]on't save this session on exit" },
  },
}
