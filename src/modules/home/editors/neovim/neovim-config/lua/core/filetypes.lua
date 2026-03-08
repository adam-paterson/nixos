-- ╭─────────────────────────────────────────────────────────╮
-- │ Filetype Associations                                     │
-- ╰─────────────────────────────────────────────────────────╯

return {
  extension = {
    ["nix"] = "nix",
    ["go"] = "go",
    ["rs"] = "rust",
    ["py"] = "python",
    ["cs"] = "cs",
    ["csproj"] = "xml",
    ["sln"] = "text",
    ["tsx"] = "typescriptreact",
    ["jsx"] = "javascriptreact",
    ["mts"] = "typescript",
    ["cts"] = "typescript",
    ["env"] = "sh",
    ["env.example"] = "sh",
  },
  filename = {
    ["justfile"] = "just",
    [".justfile"] = "just",
    ["Justfile"] = "just",
    ["flake.lock"] = "json",
  },
  pattern = {
    ["%.env%.[%w_.-]+"] = "sh",
    ["%.gitlab%-ci.*%.yml"] = "yaml.gitlab",
  },
}
