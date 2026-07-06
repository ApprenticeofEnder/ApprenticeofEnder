{
  config,
  lib,
  pkgs,
  ...
}: let
  # for more config: https://github.com/tejas-codex/vibe-terminal/blob/main/config/tmux.conf
  extraConfig = ''
    set -g allow-passthrough on
    set -s extended-keys on
    set -as terminal-features 'xterm*:extkeys'
    set -ga terminal-overrides ",xterm-ghostty:RGB,*256col*:RGB"

    bind | split-window -h -c "#{pane_current_path}"
    bind - split-window -v -c "#{pane_current_path}"
    bind c new-window -c "#{pane_current_path}"
    bind x kill-pane
    unbind '"'
    unbind %

    bind -T copy-mode-vi v send -X begin-selection
    bind -T copy-mode-vi y send -X copy-selection-and-cancel

    bind r source-file ${config.xdg.configHome}/tmux/tmux.conf \; display "\tConfig reloaded!"

    set -g @resurrect-capture-pane-contents 'on'
    set -g @resurrect-processes 'claude "claude -c" nvim vim btop htop node "~yazi" ssh'
    set -g @resurrect-strategy-nvim 'session'

    set -gu default-command
  '';
in {
  programs.tmux = {
    enable = true;
    inherit extraConfig;

    # keep-sorted start block=yes
    aggressiveResize = true;
    clock24 = true;
    escapeTime = 0;
    focusEvents = true;
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      # keep-sorted start
      continuum
      nord
      pain-control
      resurrect
      tmux-fzf
      tmux-which-key
      # keep-sorted end
    ];
    sensibleOnTop = true;
    shell = "${lib.getExe pkgs.fish}";
    shortcut = "a";
    # keep-sorted end

    tmuxinator = {
      enable = true;
      projects = {
        personal = {
          root = "~/ApprenticeofEnder";
          name = "personal";
          windows = [
            {
              dev = {
                layout = "main-vertical";
                panes = [
                  {
                    editor = [
                      "nvim"
                    ];
                  }
                  {
                    git = [
                      "lazygit"
                    ];
                  }
                  "fish"
                ];
              };
            }
          ];
        };
      };
    };
  };
}
