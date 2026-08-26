-- toggleterm: persistent floating terminals, toggled with one keymap, for
-- one-off shell commands (git pull, npm test, lazygit, etc) without ever
-- leaving Neovim. "Persistent" means hiding one (same keymap) and reopening
-- it later keeps its scrollback and running process (a dev server, a REPL)
-- -- unlike plain :! or a fresh :terminal each time.
--
-- <leader>tt toggles terminal 1. Prefixing with a count opens/toggles a
-- different numbered terminal (e.g. 2<leader>tt for a second, independent
-- terminal -- its own buffer, scrollback, and process). Terminal mode has no
-- count mapping (README: a count can't be typed from terminal-insert mode
-- anyway) -- the plain toggle there just hides whichever terminal is
-- currently focused, rather than forcing back to terminal 1.
--
-- NOTE: with direction = 'float', only one numbered terminal can be *on
-- screen* at a time -- toggleterm auto-closes a floating terminal's window
-- on WinLeave, so switching to terminal 2 hides terminal 1's window. Its
-- buffer/job/scrollback aren't touched though (confirmed headlessly), so
-- switching back to it (e.g. <leader>tt) reopens instantly with everything
-- intact -- "independent" means separate state, not simultaneously visible.
-- lazygit gets its own dedicated terminal (rather than reusing the numbered
-- <leader>tt terminals above) so toggling it never collides with whatever
-- shell command happens to be running in terminal 1/2/etc. Built once and
-- reused via :toggle() -- not recreated on every keypress -- so repeated
-- <leader>gg presses show/hide the same instance instead of spawning a new
-- lazygit process each time.
local lazygit

local function toggle_lazygit()
  lazygit = lazygit
    or require('toggleterm.terminal').Terminal:new {
      cmd = 'lazygit',
      hidden = true,
      direction = 'float',
      float_opts = { border = 'curved' },
    }
  lazygit:toggle()
end

return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = {
    direction = 'float',
    float_opts = { border = 'curved' },
  },
  keys = {
    {
      '<leader>tt',
      function() vim.cmd(vim.v.count1 .. 'ToggleTerm') end,
      desc = 'Toggle terminal N (prefix with a count, e.g. 2<leader>tt)',
      mode = 'n',
    },
    { '<leader>tt', '<cmd>ToggleTerm<CR>', desc = 'Hide/restore current terminal', mode = 't' },
    { '<leader>gg', toggle_lazygit, desc = '[G]it (lazygit)' },
  },
}
