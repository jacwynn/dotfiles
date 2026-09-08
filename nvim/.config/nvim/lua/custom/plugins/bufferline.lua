-- bufferline.nvim: a VS Code-style tab strip across the top of the editor,
-- one tab per open buffer -- a persistent, glanceable list of what's open.
-- Complements rather than replaces the <leader><leader> Telescope buffer
-- picker: tabs are for quick visual switching/closing among a handful of
-- open files, Telescope stays the better tool once there are too many
-- buffers open to scan the tab strip.
--
-- Icons need nvim-web-devicons (declared as a dependency here, and already
-- installed elsewhere as Telescope's icon dependency) -- gated on
-- have_nerd_font, flipped on in init.lua alongside this plugin.
--
-- Left on bufferline's own default separator style -- a custom trapezoid/
-- arrow separator and matching tab colors were tried (to fix low contrast
-- between inactive tabs and the editor background, and to match a
-- trapezoid-tab reference screenshot), but every attempt showed some kind
-- of rendering glitch (a wrong-colored notch/seam) in this terminal/font
-- that couldn't be fully resolved, so reverted rather than keep guessing.
-- Tab groups (clustering tabs by file pattern -- ISML templates, tests,
-- config files) were also tried and removed -- didn't end up adding real
-- value in practice.
return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VeryLazy',
  opts = {
    options = {
      -- Always show the tab strip, even with a single buffer open -- so it
      -- doesn't pop in/out of existence as you open a second file.
      always_show_bufferline = true,
      diagnostics = 'nvim_lsp',
      -- No per-tab close icon (mouse-oriented) -- <leader>bd below is the
      -- keyboard way to close a tab.
      show_buffer_close_icons = false,
      show_close_icon = false,
      -- Minimum tab width -- bufferline's default (18) packed short
      -- filenames in tightly with barely any breathing room on either
      -- side. Padding is implicit: bufferline centers the name/icon within
      -- whatever space tab_size allows, rather than there being a
      -- dedicated "padding" setting.
      tab_size = 24,
    },
  },
  keys = {
    { '<S-h>', '<cmd>BufferLineCyclePrev<CR>', desc = 'Previous tab' },
    { '<S-l>', '<cmd>BufferLineCycleNext<CR>', desc = 'Next tab' },
    { '<leader>bd', '<cmd>bdelete<CR>', desc = '[B]uffer: [d]elete (close tab)' },
    -- <leader>t1-t9, not <leader>1-9 -- harpoon.lua's own <leader>1-7 jump
    -- keys silently won them (identical key sequences, not a
    -- prefix/timeoutlen situation -- whichever plugin's vim.keymap.set or
    -- lazy.nvim `keys` entry ran last simply overwrote the other's), so
    -- only <leader>8/9 ever actually worked as tab-jumps. Verified via
    -- vim.fn.maparg after a real startup, not assumed.
    { '<leader>t1', function() require('bufferline').go_to(1, true) end, desc = 'Go to tab 1' },
    { '<leader>t2', function() require('bufferline').go_to(2, true) end, desc = 'Go to tab 2' },
    { '<leader>t3', function() require('bufferline').go_to(3, true) end, desc = 'Go to tab 3' },
    { '<leader>t4', function() require('bufferline').go_to(4, true) end, desc = 'Go to tab 4' },
    { '<leader>t5', function() require('bufferline').go_to(5, true) end, desc = 'Go to tab 5' },
    { '<leader>t6', function() require('bufferline').go_to(6, true) end, desc = 'Go to tab 6' },
    { '<leader>t7', function() require('bufferline').go_to(7, true) end, desc = 'Go to tab 7' },
    { '<leader>t8', function() require('bufferline').go_to(8, true) end, desc = 'Go to tab 8' },
    { '<leader>t9', function() require('bufferline').go_to(9, true) end, desc = 'Go to tab 9' },
  },
}
