-- ╭─────────────────────────────────────────────────────────╮
-- │ LSP Configuration                                         │
-- ╰─────────────────────────────────────────────────────────╯

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "folke/neoconf.nvim", cmd = "Neoconf", config = false },
      { "folke/neodev.nvim", opts = {} },
      "mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      {
        "hrsh7th/cmp-nvim-lsp",
        cond = function()
          return require("lazy.core.config").spec.plugins["nvim-cmp"] ~= nil
        end,
      },
    },
    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
          },
        },
      },
      inlay_hints = {
        enabled = true,
      },
      capabilities = {},
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
      servers = {},
      setup = {},
    },
    config = function(_, opts)
      local lspconfig = require("lspconfig")

      -- Diagnostic configuration
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- Setup servers
      local servers = opts.servers
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities(),
        opts.capabilities or {}
      )

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then
            return
          end
        end
        pcall(function()
          lspconfig[server].setup(server_opts)
        end)
      end

      -- Get all servers from mason-lspconfig
      local mlsp = require("mason-lspconfig")
      local all_mslp_servers = {}
      local has_mappings, mappings = pcall(require, "mason-lspconfig.mappings.server")
      if has_mappings and type(mappings.lspconfig_to_package) == "table" then
        all_mslp_servers = vim.tbl_keys(mappings.lspconfig_to_package)
      end

      local ensure_installed = {}
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          local should_use_mason = server_opts.mason ~= false and vim.tbl_contains(all_mslp_servers, server)
          if not should_use_mason then
            setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      if require("lazy.core.config").spec.plugins["mason.nvim"] then
        mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
      end
    end,
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = {
      format = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
      },
      formatters_by_ft = {},
      formatters = {
        injected = { options = { ignore_errors = true } },
      },
    },
  },

  -- Linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      linters_by_ft = {},
      linters = {},
    },
    config = function(_, opts)
      local lint = require("lint")
      lint.linters_by_ft = opts.linters_by_ft

      -- Create autocommand for linting
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
