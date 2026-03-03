local M = {}

local catppuccin_schemes = {
  mocha = "Catppuccin Mocha",
  macchiato = "Catppuccin Macchiato",
  frappe = "Catppuccin Frappe",
  latte = "Catppuccin Latte",
}

function M.apply(config, user)
  local flavor = user.theme.flavor or "mocha"
  local scheme = catppuccin_schemes[flavor] or catppuccin_schemes.mocha

  config.color_scheme = scheme
  config.colors = {
    tab_bar = {
      background = "#1e1e2e",
      inactive_tab_edge = "#313244",
      active_tab = {
        bg_color = "#89b4fa",
        fg_color = "#1e1e2e",
      },
      inactive_tab = {
        bg_color = "#181825",
        fg_color = "#9399b2",
      },
      inactive_tab_hover = {
        bg_color = "#313244",
        fg_color = "#cdd6f4",
      },
    },
  }
end

return M
