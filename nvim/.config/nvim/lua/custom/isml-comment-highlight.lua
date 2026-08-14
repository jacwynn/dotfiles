-- Renders <iscomment>...</iscomment> blocks as real comments. ISML's own
-- block-comment tag (everything inside is stripped at render time, same idea
-- as SFCC's <!--- ... ---> HTML-comment convention) -- but the base html
-- grammar has no idea "iscomment" is special, so it highlights the tag name
-- as @keyword (via the is*-prefix override in after/queries/html/highlights.scm)
-- and whatever's inside as ordinary markup/text, same as any other element.
--
-- One grammar node can't be told "render your whole subtree as @comment" via
-- a query alone once it contains nested tags (real examples commonly wrap a
-- nested <isinclude .../>), so this scans buffer text directly for
-- <iscomment>...</iscomment> spans and overlays a single @comment extmark
-- across the whole block, tags included -- the same "poor man's override"
-- approach isml-expr-highlight.lua uses for ${...} expressions.
local M = {}

local ns = vim.api.nvim_create_namespace 'isml_comment_highlight'

local OPEN_PATTERN = '<iscomment[^>]*>'
local CLOSE_TAG = '</iscomment>'

local function highlight_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local text = table.concat(lines, '\n')

  -- byte offset (1-based, start of each line) -> line index (0-based)
  local line_starts = {}
  do
    local offset = 1
    for i, line in ipairs(lines) do
      line_starts[i] = offset
      offset = offset + #line + 1
    end
  end

  ---Convert a 1-based byte offset into `text` to a 0-based (row, col).
  local function pos_at(byte_idx)
    for i = #line_starts, 1, -1 do
      if byte_idx >= line_starts[i] then return i - 1, byte_idx - line_starts[i] end
    end
    return 0, byte_idx - 1
  end

  local search_from = 1
  while true do
    local open_start, open_end = text:find(OPEN_PATTERN, search_from)
    if not open_start then break end

    local close_start, close_end = text:find(CLOSE_TAG, open_end + 1, true)
    if not close_start then
      -- No closing tag found (malformed, or this is the last unmatched
      -- <iscomment> in the buffer) -- skip past this opener and keep
      -- scanning, rather than abandoning the rest of the buffer.
      search_from = open_end + 1
    else
      local srow, scol = pos_at(open_start)
      local erow, ecol = pos_at(close_end + 1)
      vim.api.nvim_buf_set_extmark(bufnr, ns, srow, scol, {
        end_row = erow,
        end_col = ecol,
        hl_group = '@comment',
        -- Higher than isml-expr-highlight.lua's 200, so a commented-out
        -- block that happens to contain a ${...} expression still reads as
        -- one uniform comment instead of partially re-lit as JavaScript.
        priority = 250,
      })
      search_from = close_end + 1
    end
  end
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'TextChanged', 'TextChangedI', 'InsertLeave' }, {
  desc = 'Render <iscomment>...</iscomment> blocks as real comments',
  group = vim.api.nvim_create_augroup('isml-comment-highlight', { clear = true }),
  pattern = '*.isml',
  callback = function(args)
    local ok, err = pcall(highlight_buffer, args.buf)
    if not ok then vim.notify('isml-comment-highlight error: ' .. tostring(err), vim.log.levels.ERROR) end
  end,
})

return M
