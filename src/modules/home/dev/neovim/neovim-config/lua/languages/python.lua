-- ╭─────────────────────────────────────────────────────────╮
-- │ Python Language Configuration                             │
-- ╰─────────────────────────────────────────────────────────╯

return {
  -- Treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "python",
          "requirements",
        })
      end
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoImportCompletions = true,
                diagnosticMode = "workspace",
                inlayHints = {
                  callArgumentNames = true,
                  functionReturnTypes = true,
                  variableTypes = true,
                },
              },
            },
          },
        },
        ruff = {
          settings = {
            lint = {
              select = { "E", "F", "I" },
            },
          },
        },
      },
    },
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "black" },
      },
    },
  },

  -- Linting
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        python = { "ruff" },
      },
    },
  },

  -- DAP for Python
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "mfussenegger/nvim-dap-python",
        config = function()
          local python_path = "python3"
          local ok, registry = pcall(require, "mason-registry")
          if ok and registry.has_package and registry.has_package("debugpy") then
            local pkg = registry.get_package("debugpy")
            local install_path = pkg and pkg.get_install_path and pkg:get_install_path() or nil
            if install_path then
              python_path = install_path .. "/venv/bin/python"
            end
          end
          require("dap-python").setup(python_path)
        end,
      },
    },
  },

  -- Additional Python plugins
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    cmd = "VenvSelect",
    opts = {
      name = { "venv", ".venv", "env", ".env" },
      parents = 2,
    },
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
    },
  },
}
