# ╭──────────────────────────────────────────────────────────╮
# │ Oh-My-Posh - Beautiful Cross-Shell Prompt                │
# ╰──────────────────────────────────────────────────────────╯
{
  config,
  lib,
  pkgs,
  ...
}: {
  options.local.oh-my-posh = {
    enable = lib.mkEnableOption "Oh-My-Posh prompt";
  };

  config = lib.mkIf config.local.oh-my-posh.enable {
    programs.oh-my-posh = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;

      # Catppuccin Mocha themed prompt with useful information
      settings = {
        version = 2;
        final_space = true;
        console_title_template = "{{ .Folder }}";

        blocks = [
          {
            type = "prompt";
            alignment = "left";
            segments = [
              {
                type = "os";
                style = "plain";
                foreground = "#cdd6f4";
                template = "{{ .Icon }}  ";
              }
              {
                type = "path";
                style = "plain";
                foreground = "#89b4fa";
                template = "{{ .Path }} ";
                properties = {
                  style = "full";
                  folder_separator_icon = " <#585b70>/</> ";
                };
              }
              {
                type = "git";
                style = "plain";
                foreground = "#a6e3a1";
                foreground_templates = [
                  "{{ if or (.Working.Changed) (.Staging.Changed) }}#f9e2af{{ end }}"
                  "{{ if and (gt .Ahead 0) (gt .Behind 0) }}#f5c2e7{{ end }}"
                  "{{ if gt .Ahead 0 }}#89b4fa{{ end }}"
                  "{{ if gt .Behind 0 }}#eba0ac{{ end }}"
                ];
                template = "{{ .HEAD }} {{ if .Working.Changed }}{{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }}<#a6e3a1> {{ .Staging.String }}</>{{ end }} ";
                properties = {
                  branch_icon = " ";
                  commit_icon = " ";
                  fetch_status = true;
                };
              }
              {
                type = "nix";
                style = "plain";
                foreground = "#74c7ec";
                template = " ";
              }
            ];
          }
          {
            type = "prompt";
            alignment = "right";
            segments = [
              {
                type = "executiontime";
                style = "plain";
                foreground = "#fab387";
                template = "{{ .FormattedMs }} ";
                properties = {
                  threshold = 500;
                  style = "austin";
                };
              }
              {
                type = "status";
                style = "plain";
                foreground = "#f38ba8";
                foreground_templates = [
                  "{{ if gt .Code 0 }}#f38ba8{{ end }}"
                ];
                template = "{{ if gt .Code 0 }}{{ .Code }}{{ end }} ";
                properties = {
                  always_enabled = false;
                };
              }
            ];
          }
          {
            type = "prompt";
            alignment = "left";
            newline = true;
            segments = [
              {
                type = "text";
                style = "plain";
                foreground = "#cdd6f4";
                template = "❯";
              }
            ];
          }
        ];

        transient_prompt = {
          foreground = "#cdd6f4";
          foreground_templates = [
            "{{ if gt .Code 0 }}#f38ba8{{ end }}"
          ];
          template = "❯ ";
        };

        secondary_prompt = {
          foreground = "#585b70";
          template = "❯❯ ";
        };
      };
    };
  };
}
