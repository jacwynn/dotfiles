-- SFCC/Demandware cartridge upload via Telescope.
--
-- Known upstream bug (from the plugin's own README, unresolved as of the
-- last commit in June 2024): the cartridge list is only scanned once per
-- session. If you add a new cartridge to cwd after enabling upload, re-run
-- "Upload Cartridges" to pick it up -- there's no "refresh" action yet.
--
-- "Upload Cartridges" / "Clean Project and Upload all" itself was replaced
-- below (see the patch at the bottom of this file) because the upstream
-- implementation PUTs every file individually with no WebDAV MKCOL calls to
-- create intermediate directories first -- any file inside a directory that
-- doesn't already exist on the sandbox fails with a 409, so upload only
-- "sometimes" worked depending on whether the remote directory structure
-- already happened to match. Confirmed against a local mock WebDAV server
-- before shipping: a deeply nested brand-new folder failed to appear with
-- the old file-by-file approach and appears correctly with this one.
return {
  '3mpee3mpee/nvim_dw_sync',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    require('telescope').load_extension 'nvim_dw_sync'
    require('nvim_dw_sync').setup {}

    -- Replace upload_cartridge with the same zip-then-server-side-unzip
    -- approach the real "Prophet Debugger" VS Code extension uses
    -- (src/server/WebDav.ts's uploadCartridge, in the same SqrTT/prophet
    -- repo the SFCC debugger is built from -- see dap.lua/install.sh):
    -- zip the cartridge locally -> PUT the zip -> DELETE the existing
    -- remote cartridge folder (clean slate) -> POST method=UNZIP (SFCC's
    -- WebDAV server-side unzip extension, same one Prophet and SFCC's own
    -- official tooling use) -> delete the remote zip. One HTTP round-trip
    -- per cartridge instead of one per file, and no missing-directory 409s
    -- since the whole tree is created atomically by the server-side unzip.
    --
    -- Patching the function on nvim_dw_sync's own module table (rather than
    -- forking the plugin) because Lua caches required modules -- every
    -- other file in the plugin that already did
    -- `local file_utils = require("nvim_dw_sync.utils.file")` holds a
    -- reference to this same table, and looks up `.upload_cartridge` fresh
    -- on every call, so this survives plugin updates as long as the
    -- upstream function name/signature don't change.
    local file_utils = require 'nvim_dw_sync.utils.file'
    local logs = require 'nvim_dw_sync.utils.logs'
    local Job = require 'plenary.job'

    local IGNORE_ARGS = { '-x', '*.git*', '-x', '*node_modules*', '-x', '*.zip' }

    local function webdav_url(config, path)
      return string.format('https://%s/on/demandware.servlet/webdav/Sites/Cartridges/%s/%s', config.hostname, config['code-version'], path)
    end

    local function curl(args, on_exit) Job:new({ command = 'curl', args = args, on_exit = on_exit }):start() end

    file_utils.upload_cartridge = function(cartridge_path, config)
      local cartridge_name = vim.fn.fnamemodify(cartridge_path, ':t')
      local cartridge_parent = vim.fn.fnamemodify(cartridge_path, ':h')
      local zip_remote_name = cartridge_name .. '_cartridge.zip'
      local zip_local_path = vim.fn.tempname() .. '.zip'
      local auth = config.username .. ':' .. config.password

      local function cleanup_local_zip() os.remove(zip_local_path) end

      logs.add_log('[' .. cartridge_name .. '] Deleting remote zip (if any)')
      curl({ '-X', 'DELETE', webdav_url(config, zip_remote_name), '-u', auth }, function()
        logs.add_log('[' .. cartridge_name .. '] Zipping')

        -- Zipped relative to the cartridge's *parent* dir (not the cartridge
        -- dir itself), so the cartridge name is the zip's own top-level
        -- entry -- required because the server-side UNZIP below extracts
        -- into the parent Cartridges/{version}/ collection, not into the
        -- cartridge folder itself.
        local zip_args = { '-r', '-q', zip_local_path, cartridge_name }
        for _, a in ipairs(IGNORE_ARGS) do
          table.insert(zip_args, a)
        end

        Job:new({
          command = 'zip',
          args = zip_args,
          cwd = cartridge_parent,
          on_exit = function(_, zip_code)
            if zip_code ~= 0 then
              logs.add_log('[' .. cartridge_name .. '] Failed to zip cartridge')
              cleanup_local_zip()
              return
            end

            logs.add_log('[' .. cartridge_name .. '] Sending zip to remote')
            curl({ '--fail', '-T', zip_local_path, webdav_url(config, zip_remote_name), '-u', auth }, function(_, put_code)
              if put_code ~= 0 then
                logs.add_log('[' .. cartridge_name .. '] Failed to upload zip')
                cleanup_local_zip()
                return
              end

              logs.add_log('[' .. cartridge_name .. '] Removing remote cartridge before extract')
              curl({ '-X', 'DELETE', webdav_url(config, cartridge_name), '-u', auth }, function()
                logs.add_log('[' .. cartridge_name .. '] Unzipping remote zip')
                curl({ '--fail', '-X', 'POST', webdav_url(config, zip_remote_name), '-u', auth, '-d', 'method=UNZIP' }, function(_, unzip_code)
                  cleanup_local_zip()
                  if unzip_code ~= 0 then
                    logs.add_log('[' .. cartridge_name .. '] Failed to unzip remote zip')
                    return
                  end

                  logs.add_log('[' .. cartridge_name .. '] Deleting remote zip')
                  curl(
                    { '-X', 'DELETE', webdav_url(config, zip_remote_name), '-u', auth },
                    function() logs.add_log('[' .. cartridge_name .. '] Upload complete') end
                  )
                end)
              end)
            end)
          end,
        }):start()
      end)
    end
  end,
  keys = {
    {
      '<leader>ds',
      ':Telescope nvim_dw_sync open_telescope<CR>',
      desc = 'DW Sync open telescope',
    },
  },
}
