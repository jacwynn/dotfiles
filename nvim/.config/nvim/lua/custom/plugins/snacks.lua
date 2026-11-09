-- snacks.nvim, just the `explorer` module -- a tree-view file explorer
-- (actually a picker in disguise, built on Snacks' own picker framework)
-- swapped in for mini.files' editable-buffer-as-filesystem model. Picked
-- because mini.files' create-a-file flow (new line + `=` to synchronize,
-- confirmation dialog, `:w` doesn't work since it's a `nofile` buffer) was
-- a recurring point of friction; this has a plain `a`-to-add prompt
-- instead, plus proper multi-select, trash-based delete, and git/diagnostic
-- status in the tree.
--
-- Everything else in this config still uses mini.nvim (statusline,
-- surround, ai) and Telescope (every other picker, including file
-- *finding* via <leader>sf) -- this is scoped to the one module that
-- replaces mini.files, not a wider adoption of snacks.nvim's other 30-ish
-- modules.
--
-- `replace_netrw` and `trash` both default to true (not set here) --
-- netrw's :Ex/:Explore still gets replaced, and `d` sends to the system
-- trash rather than deleting permanently. `follow_file` also defaults to
-- true -- opening reveals/highlights the current buffer's file in the tree
-- rather than needing a separate reveal step.
return {
  'folke/snacks.nvim',
  opts = {
    explorer = {},
  },
  keys = {
    { '<leader>e', function() Snacks.explorer() end, desc = '[E]xplore files' },
  },
}
