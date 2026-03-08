-- ╭─────────────────────────────────────────────────────────╮
-- │ GitHub Copilot Configuration                              │
-- ╰─────────────────────────────────────────────────────────╯

return {
  -- Copilot
  {
    "github/copilot.vim",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_tab_fallback = ""
      vim.g.copilot_filetypes = {
        ["*"] = false,
        ["javascript"] = true,
        ["typescript"] = true,
        ["javascriptreact"] = true,
        ["typescriptreact"] = true,
        ["python"] = true,
        ["go"] = true,
        ["rust"] = true,
        ["cs"] = true,
        ["nix"] = true,
        ["lua"] = true,
        ["markdown"] = true,
        ["yaml"] = true,
        ["json"] = true,
        ["html"] = true,
        ["css"] = true,
        ["sh"] = true,
        ["bash"] = true,
        ["zsh"] = true,
      }
    end,
    keys = {
      {
        "<M-]>",
        'copilot#Accept("<CR>")',
        desc = "Accept Copilot suggestion",
        expr = true,
        replace_keycodes = false,
        mode = "i",
      },
      {
        "<M-n>",
        "<Plug>(copilot-next)",
        desc = "Next Copilot suggestion",
        mode = "i",
      },
      {
        "<M-p>",
        "<Plug>(copilot-previous)",
        desc = "Previous Copilot suggestion",
        mode = "i",
      },
      {
        "<M-d>",
        "<Plug>(copilot-dismiss)",
        desc = "Dismiss Copilot suggestion",
        mode = "i",
      },
    },
  },

  -- Copilot Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    cmd = "CopilotChat",
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken",
    opts = {
      debug = false,
      show_help = true,
      language = "English",
      prompts = {
        Explain = {
          prompt = "/COPILOT_EXPLAIN 選択したコードの説明を段落をつけて書いてください。",
        },
        Review = {
          prompt = "/COPILOT_REVIEW 選択したコードをレビューしてください。",
        },
        Fix = {
          prompt = "/COPILOT_FIX このコードには問題があります。バグを修正したコードに書き換えてください。",
        },
        Optimize = {
          prompt = "/COPILOT_OPTIMIZE 選択したコードを最適化し、パフォーマンスと可読性を向上させてください。",
        },
        Docs = {
          prompt = "/COPILOT_GENERATE 選択したコードに関するドキュメントを書いてください。",
        },
        Tests = {
          prompt = "/COPILOT_TESTS 選択したコードのテストを書いてください。",
        },
        FixDiagnostic = {
          prompt = "カーソル行の Diagnostic の問題を説明して修正してください。",
        },
        Commit = {
          prompt = "commitizen の規約に従って、ステージされた変更の commit メッセージを書いてください。タイトルは最大 50 文字、メッセージは 72 文字で折り返してください。サンプルとして 'fix: add missing parameter' という形式を使用してください。あなたの出力全体を gitcommit コード ブロックで囲んでください。",
        },
        CommitStaged = {
          prompt = "commitizen の規約に従って、ステージされた変更の commit メッセージを書いてください。タイトルは最大 50 文字、メッセージは 72 文字で折り返してください。サンプルとして 'fix: add missing parameter' という形式を使用してください。あなたの出力全体を gitcommit コード ブロックで囲んでください。",
          selection = function(source)
            return require("CopilotChat.select").gitdiff(source, true)
          end,
        },
      },
    },
    keys = {
      { "<leader>ccb", "<cmd>CopilotChatBuffer<cr>", desc = "CopilotChat - Chat with current buffer" },
      { "<leader>cce", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
      { "<leader>cct", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
      { "<leader>ccr", "<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },
      { "<leader>ccf", "<cmd>CopilotChatFix<cr>", desc = "CopilotChat - Fix code" },
      { "<leader>cco", "<cmd>CopilotChatOptimize<cr>", desc = "CopilotChat - Optimize code" },
      { "<leader>ccd", "<cmd>CopilotChatDocs<cr>", desc = "CopilotChat - Generate docs" },
      { "<leader>ccc", "<cmd>CopilotChat<cr>", desc = "CopilotChat - Open chat" },
      { "<leader>ccx", "<cmd>CopilotChatClose<cr>", desc = "CopilotChat - Close chat" },
      { "<leader>ccR", "<cmd>CopilotChatReset<cr>", desc = "CopilotChat - Reset chat" },
      {
        "<leader>ccv",
        function()
          require("CopilotChat").ask("Explain how it works", { selection = require("CopilotChat.select").visual })
        end,
        desc = "CopilotChat - Visual",
        mode = "x",
      },
    },
  },
}
