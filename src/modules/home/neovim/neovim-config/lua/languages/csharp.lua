-- ╭─────────────────────────────────────────────────────────╮
-- │ C# Language Configuration                                 │
-- ╰─────────────────────────────────────────────────────────╯

return {
  -- Treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "c_sharp" })
      end
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = {
          cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
          settings = {
            FormattingOptions = {
              EnableEditorConfigSupport = true,
              OrganizeImports = nil,
            },
            MsBuild = {
              LoadProjectsOnDemand = nil,
            },
            RoslynExtensionsOptions = {
              EnableAnalyzersSupport = true,
              EnableImportCompletion = true,
              AnalyzeOpenDocumentsOnly = nil,
            },
            Sdk = {
              IncludePrereleases = true,
            },
          },
        },
      },
    },
  },

  -- Formatting (using CSharpier if available, otherwise fallback)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
      },
      formatters = {
        csharpier = {
          command = "dotnet-csharpier",
          args = { "--write-stdout" },
        },
      },
    },
  },

  -- DAP for C#
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "williamboman/mason.nvim",
        optional = true,
        opts = function(_, opts)
          if type(opts.ensure_installed) == "table" then
            vim.list_extend(opts.ensure_installed, { "netcoredbg" })
          end
        end,
      },
    },
  },
}
