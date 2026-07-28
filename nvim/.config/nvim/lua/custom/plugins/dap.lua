-- Debugging via nvim-dap, the Neovim client for the Debug Adapter Protocol
-- (the same protocol VS Code's debugger uses -- this is the closest nvim
-- equivalent to VS Code's launch.json + debug UI).
--
-- Two things are wired up:
--   1. Generic dap/dap-ui scaffolding (keymaps, UI).
--   2. An SFCC/Demandware "prophet" adapter, talking to the same debug
--      adapter the "Prophet Debugger" VS Code extension uses (built from
--      https://github.com/SqrTT/prophet -- see install.sh for the build
--      step, which must run before this works).
--
-- SFCC handshake, verified directly against a real build of that adapter:
-- on session start it fires a custom DAP event named
-- "prophet.getdebugger.config" and then waits. The client is expected to
-- respond with a custom "DebuggerConfig" request containing the sandbox
-- credentials (read from dw.json, same file nvim_dw_sync uses) and the list
-- of cartridge directories in the project (a "cartridge" is any directory
-- containing a .project file whose content includes the marker string
-- "com.demandware.studio.core.beehiveNature" -- this is exactly what the
-- VS Code extension's own client-side code does; replicated here since
-- nvim-dap has no equivalent built in). Confirmed via a raw DAP handshake
-- test that the adapter is a genuine, protocol-compliant stdio DAP server,
-- not something VS Code-specific -- but the actual sandbox connection (SDAPI
-- 2.0, over the network) has NOT been tested against a real sandbox from
-- here and needs verification against one.
local PROPHET_ADAPTER_PATH = vim.fn.expand '~/.local/share/prophet-debugger/dist/mockDebug.js'

---@return string|nil
local function find_dw_json(start_path)
  -- Search from the current buffer's own directory (same approach the
  -- format-on-save SFCC detection uses), not vim.fn.getcwd() -- cwd can be
  -- set to anywhere (e.g. a parent monorepo folder) while editing a file
  -- deep inside a specific SFCC project.
  if not start_path then
    local bufname = vim.api.nvim_buf_get_name(0)
    start_path = bufname ~= '' and vim.fs.dirname(bufname) or vim.fn.getcwd()
  end
  return vim.fs.find('dw.json', { path = start_path, upward = true })[1]
end

---@param root string
---@return string[]
local function find_cartridges(root)
  local cartridges = {}
  local project_files = vim.fs.find(function(name) return name == '.project' end, {
    path = root,
    limit = math.huge,
    type = 'file',
  })
  for _, project_file in ipairs(project_files) do
    -- Match VS Code's default findFiles exclusions (which the real Prophet
    -- extension relies on implicitly) by skipping node_modules -- otherwise
    -- vendored copies (e.g. an sfra npm package shipping its own cartridge
    -- .project files) get picked up as duplicate/irrelevant cartridges.
    if not project_file:find('/node_modules/', 1, true) then
      local f = io.open(project_file, 'r')
      if f then
        local content = f:read '*a'
        f:close()
        if content:find('com.demandware.studio.core.beehiveNature', 1, true) then
          table.insert(cartridges, vim.fs.dirname(project_file))
        end
      end
    end
  end
  return cartridges
end

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio', -- required by nvim-dap-ui
  },
  keys = {
    { '<F5>', function() require('dap').continue() end, desc = 'Debug: Start/Continue' },
    { '<F1>', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
    { '<F2>', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
    { '<F3>', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
    { '<leader>b', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle Breakpoint' },
    { '<leader>B', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = 'Debug: Set Breakpoint' },
    { '<F7>', function() require('dapui').toggle() end, desc = 'Debug: See last session result' },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    ---@diagnostic disable-next-line: missing-fields
    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
    }

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- SFCC/Demandware: Prophet debug adapter
    dap.adapters.prophet = {
      type = 'executable',
      command = 'node',
      args = { PROPHET_ADAPTER_PATH },
    }

    dap.listeners.after['event_prophet.getdebugger.config']['prophet_send_config'] = function(session, _body)
      local dw_json_path = find_dw_json()
      if not dw_json_path then
        vim.notify('Prophet debugger: no dw.json found in this project', vim.log.levels.ERROR)
        return
      end

      local f = io.open(dw_json_path, 'r')
      if not f then
        vim.notify('Prophet debugger: could not read ' .. dw_json_path, vim.log.levels.ERROR)
        return
      end
      local content = f:read '*a'
      f:close()

      local ok, config = pcall(vim.json.decode, content)
      if not ok then
        vim.notify('Prophet debugger: failed to parse dw.json as JSON', vim.log.levels.ERROR)
        return
      end

      local cartridges = find_cartridges(vim.fs.dirname(dw_json_path))
      if #cartridges == 0 then
        vim.notify('Prophet debugger: no cartridges found (no .project files with the SFCC marker)', vim.log.levels.WARN)
      end

      -- TEMPORARY diagnostic: adapter's Connection class checks config.verbose
      -- and, if set, logs every raw request/response body (routed through the
      -- same OutputEvent channel dap.log already captures). Needed to see the
      -- actual sandbox response causing `body.breakpoints.map` and the /threads
      -- JSON.parse failures -- remove once that's identified.
      config.verbose = true

      session:request('DebuggerConfig', { config = config, cartridges = cartridges })
    end

    dap.configurations.javascript = dap.configurations.javascript or {}
    table.insert(dap.configurations.javascript, {
      type = 'prophet',
      request = 'launch',
      name = 'SFCC: Attach to Sandbox',
      -- Enables the adapter's own verbose logging (its source checks
      -- args.trace and switches to Logger.LogLevel.Verbose + logToFile).
      -- Temporary, for diagnosing the /threads polling failure -- remove
      -- once that's resolved.
      trace = true,
    })

    -- Also log the raw DAP protocol traffic nvim-dap sends/receives, so we
    -- can see exactly what setBreakpoints/configurationDone sequence goes
    -- out relative to launch -- not just what the adapter itself logs.
    -- Log file: :lua print(require('dap').session and vim.fn.stdpath('log') .. '/dap.log' or 'no active session')
    dap.set_log_level 'TRACE'
  end,
}
