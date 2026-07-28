-- Vertical lines through each indent level, so nested opening/closing
-- pairs (divs, braces, ISML blocks) are easy to trace visually. `scope`
-- additionally underlines the start and end line of whatever block the
-- cursor is currently inside -- e.g. put the cursor on a div's contents
-- and both its opening and closing tag get underlined.
return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    indent = { char = '│' },
    scope = { enabled = true, show_start = true, show_end = true },
  },
}
