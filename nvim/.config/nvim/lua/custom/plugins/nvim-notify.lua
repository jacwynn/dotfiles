-- nvim-notify: replaces vim.notify() (used by Neovim itself and every
-- plugin's own notify calls -- the buffer auto-reload notice, the ISML
-- highlighter's error notify, etc) with animated floating toast popups
-- instead of a plain one-line message at the bottom of the screen.
--
-- No overlap with fidget.nvim: fidget's own override_vim_notify option
-- defaults to false (confirmed in its source, and this config uses
-- fidget's defaults), so fidget only ever renders LSP $/progress messages
-- in its own corner widget -- it never touches vim.notify() at all.
return {
  'rcarriga/nvim-notify',
  config = function()
    require('notify').setup {
      stages = 'fade_in_slide_out',
      timeout = 3000,
    }
    vim.notify = require 'notify'
  end,
}
