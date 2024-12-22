return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "3mpee3mpee/nvim_dw_sync",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    config = function ()
      require("telescope").load_extension("nvim_dw_sync")
      require("nvim_dw_sync").setup({})
    end,
    key = {
      "<Leader>ds",
      ":Telescope nvim_dw_sync open_telescope<CR>",
      desc = "DW Sync open telescope",
    }
  },

  {
   	"nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css", "scss", "c"
      }
    }
  },
}
