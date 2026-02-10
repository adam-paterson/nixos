# ╭──────────────────────────────────────────────────────────╮
# │ Tmux - Terminal Multiplexer                              │
# ╰──────────────────────────────────────────────────────────╯
{
  config,
  lib,
  pkgs,
  ...
}: {
  options.local.tmux = {
    enable = lib.mkEnableOption "Tmux configuration";
  };

  config = lib.mkIf config.local.tmux.enable {
    programs.tmux = {
      enable = true;

      # Prefix key: Ctrl+a (like screen)
      prefix = "C-a";

      # Terminal settings
      terminal = "tmux-256color";
      escapeTime = 10;
      historyLimit = 50000;

      # Mouse support
      mouse = true;

      # Base index
      baseIndex = 1;

      # Use Nushell as default shell
      shell = "${pkgs.nushell}/bin/nu";

      # Extra configuration
      extraConfig = ''
        # ╭────────────────────────────────────────────────────────╮
        # │ Key Bindings                                           │
        # ╰────────────────────────────────────────────────────────╯

        # Unbind default prefix
        unbind C-b

        # Send prefix to nested tmux
        bind a send-prefix

        # Reload config
        bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

        # Split panes using | and -
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        unbind '"'
        unbind %

        # Vim-style pane navigation
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Resize panes
        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5

        # Window navigation
        bind -r C-h select-window -t :-
        bind -r C-l select-window -t :+

        # Swap windows
        bind -r < swap-window -t -1
        bind -r > swap-window -t +1

        # ╭────────────────────────────────────────────────────────╮
        # │ Copy Mode                                              │
        # ╰────────────────────────────────────────────────────────╯

        # Vim-style copy mode
        setw -g mode-keys vi

        # Copy mode keybindings
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        # ╭────────────────────────────────────────────────────────╮
        # │ Appearance - Catppuccin Mocha                          │
        # ╰────────────────────────────────────────────────────────╯

        # Status bar position
        set -g status-position bottom

        # Status bar colors (Catppuccin Mocha)
        set -g status-style "bg=#1e1e2e,fg=#cdd6f4"

        # Status bar left
        set -g status-left-length 100
        set -g status-left "#[bg=#89b4fa,fg=#1e1e2e,bold] #S #[bg=#1e1e2e,fg=#89b4fa] "

        # Status bar right
        set -g status-right-length 100
        set -g status-right "#[fg=#6c7086] %Y-%m-%d %H:%M #[bg=#cba6f7,fg=#1e1e2e,bold] #h "

        # Window status
        set -g window-status-format "#[fg=#6c7086] #I:#W "
        set -g window-status-current-format "#[bg=#313244,fg=#cdd6f4,bold] #I:#W "
        set -g window-status-separator ""

        # Pane borders
        set -g pane-border-style "fg=#313244"
        set -g pane-active-border-style "fg=#89b4fa"

        # Message style
        set -g message-style "bg=#313244,fg=#cdd6f4"
        set -g message-command-style "bg=#313244,fg=#cdd6f4"

        # ╭────────────────────────────────────────────────────────╮
        # │ Miscellaneous                                          │
        # ╰────────────────────────────────────────────────────────╯

        # Focus events
        set -g focus-events on

        # Aggressive resize
        setw -g aggressive-resize on

        # Renumber windows
        set -g renumber-windows on

        # Set window notifications
        setw -g monitor-activity on
        set -g visual-activity off

        # Automatic rename
        setw -g automatic-rename on
      '';

      # Plugins
      plugins = with pkgs.tmuxPlugins; [
        # Vim-tmux-navigator for seamless navigation between vim and tmux
        vim-tmux-navigator

        # Yank for copying to system clipboard
        yank

        # Pain control for better pane management
        pain-control

        # Session management
        {
          plugin = pkgs.tmuxPlugins.session-wizard;
          extraConfig = ''
            set -g @session-wizard 'T'
          '';
        }
      ];
    };

    # Install tmux-sessionizer for quick session switching
    home.packages = with pkgs; [
      tmux-sessionizer
      fzf
    ];
  };
}
