-- toggleterm: a persistent floating terminal, toggled with one keymap, for
-- one-off shell commands (git pull, npm test, lazygit, etc) without ever
-- leaving Neovim. "Persistent" means hiding it (same keymap) and reopening
-- later keeps its scrollback and running process (a dev server, a REPL) --
-- unlike plain :! or a fresh :terminal each time.
return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = {
    direction = 'float',
    float_opts = { border = 'curved' },
  },
  keys = {
    { '<leader>tt', '<cmd>ToggleTerm<CR>', desc = 'Toggle floating terminal', mode = { 'n', 't' } },
  },
}
