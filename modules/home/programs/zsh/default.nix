{
  pkgs,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;
    autocd = false;
    enableCompletion = true;
    shellAliases = {
      mkdir = "mkdir -p";
    };
    sessionVariables =
      {}
      // lib.mkIf pkgs.stdenv.isDarwin {
        LIBRARY_PATH = "${pkgs.libiconv}/lib";
      };

    history = {
      size = 10000;
      save = 10000;
      share = true;
      append = true;
      extended = true;
      ignoreDups = true;
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
    };

    autosuggestion = {
      enable = true;
      strategy = [
        "history"
        "completion"
      ];
    };

    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "line"
        "main"
        "root"
        "regexp"
        "pattern"
        "brackets"
      ];
    };

    initContent = builtins.readFile ./init-extra.zsh;

    oh-my-zsh = {
      enable = true;
      theme = "nanotech";
      plugins =
        [
          "uv"
          "fzf"
          "git"
          "sudo"
          "rust"
          "direnv"
          "docker"
          "podman"
          "kubectl"
          "colorize"
          "opentofu"
          "safe-paste"
          "docker-compose"
          "colored-man-pages"
        ]
        ++ lib.optionals pkgs.stdenv.isDarwin [
          "dash"
          "macos"
          "dotnet"
        ]
        ++ lib.optionals pkgs.stdenv.isLinux [
          "systemd"
        ];
      extraConfig = ''
        zstyle ':omz:update' mode reminder
      '';
    };
  };
}
