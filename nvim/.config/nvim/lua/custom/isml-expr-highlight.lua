-- Real syntax highlighting for ISML's embedded script expressions
-- (`${pdict.Basket.productLineItems.size > 0}`), wherever they appear --
-- inside a tag attribute (`class="foo ${bar}"`) or directly as page text
-- (`${cond ? a : b}`).
--
-- The bundled html treesitter grammar doesn't know ISML exists: it treats
-- attribute values and text as opaque strings, with exactly one built-in
-- injection rule (from lit-html support) that assumes the *entire* string is
-- one `${...}` block. That's true for lit-html's own conventions but not for
-- ISML, where `${...}` is routinely mixed with literal surrounding text
-- (`class="enroll-message ${isMemberLinked ? 'linked' : ''}"`) or used
-- standalone as page text with no attribute at all. Neither case is
-- expressible as a single per-node injection, since one grammar node can
-- only carry one injected range -- so this scans buffer text directly for
-- every `${...}` run, parses each one as real JavaScript via
-- vim.treesitter.get_string_parser, and places the resulting highlight
-- captures as extmarks translated back to buffer coordinates.
local M = {}

local ns = vim.api.nvim_create_namespace 'isml_expr_highlight'

---Find the byte index (1-based, inclusive) of the `}` matching the `{` at
---`brace_idx`, accounting for nested braces.
---@return integer? close_idx
local function find_matching_brace(text, brace_idx)
  local depth = 1
  local i = brace_idx + 1
  local len = #text
  while i <= len do
    local c = text:sub(i, i)
    if c == '{' then
      depth = depth + 1
    elseif c == '}' then
      depth = depth - 1
      if depth == 0 then return i end
    end
    i = i + 1
  end
  return nil
end

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

  local js_query = vim.treesitter.query.get('javascript', 'highlights')
  if not js_query then return end

  local search_from = 1
  while true do
    local open_idx = text:find('%${', search_from)
    if not open_idx then break end
    local close_idx = find_matching_brace(text, open_idx + 1)
    if not close_idx then break end

    local expr = text:sub(open_idx + 2, close_idx - 1)
    local expr_start_row, expr_start_col = pos_at(open_idx + 2)

    -- Delimiters themselves get a distinct punctuation highlight.
    local orow, ocol = pos_at(open_idx)
    vim.api.nvim_buf_set_extmark(bufnr, ns, orow, ocol, {
      end_row = orow,
      end_col = ocol + 2,
      hl_group = '@punctuation.special',
      priority = 200,
    })
    local crow, ccol = pos_at(close_idx)
    vim.api.nvim_buf_set_extmark(bufnr, ns, crow, ccol - 1, {
      end_row = crow,
      end_col = ccol,
      hl_group = '@punctuation.special',
      priority = 200,
    })

    local ok, parser = pcall(vim.treesitter.get_string_parser, expr, 'javascript')
    if ok then
      local trees = parser:parse()
      local root = trees[1]:root()
      for id, node in js_query:iter_captures(root, expr) do
        local capture_name = js_query.captures[id]
        local nsrow, nscol, nerow, necol = node:range()

        local abs_srow = expr_start_row + nsrow
        local abs_scol = (nsrow == 0) and (expr_start_col + nscol) or nscol
        local abs_erow = expr_start_row + nerow
        local abs_ecol = (nerow == 0) and (expr_start_col + necol) or necol

        -- Skip zero-width/invalid ranges (can happen on error-recovery nodes).
        if abs_srow < abs_erow or (abs_srow == abs_erow and abs_scol < abs_ecol) then
          vim.api.nvim_buf_set_extmark(bufnr, ns, abs_srow, abs_scol, {
            end_row = abs_erow,
            end_col = abs_ecol,
            hl_group = '@' .. capture_name,
            priority = 200,
          })
        end
      end
    end

    search_from = close_idx + 1
  end
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'TextChanged', 'TextChangedI', 'InsertLeave' }, {
  desc = 'Highlight embedded ISML script expressions (${...}) as real JavaScript',
  group = vim.api.nvim_create_augroup('isml-expr-highlight', { clear = true }),
  pattern = '*.isml',
  callback = function(args)
    local ok, err = pcall(highlight_buffer, args.buf)
    if not ok then vim.notify('isml-expr-highlight error: ' .. tostring(err), vim.log.levels.ERROR) end
  end,
})

return M
