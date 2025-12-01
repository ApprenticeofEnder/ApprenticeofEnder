{ pkgs
, lib
, config
, ...
}:
{
  programs.zsh = {
    enable = true;
    autocd = false;
    enableCompletion = true;
    shellAliases = {
      mkdir = "mkdir -p";
    };

    # plugins = [
    #   {
    #     name = "1password";
    #     src = ./plugins/1password/1password.plugin.zsh;
    #     file = "1password/1password.plugin.zsh";
    #   }
    # ];

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
      plugins = [
        "git"
        "sudo"
        "direnv"
        "docker"
        "kubectl"
        "colorize"
        "docker-compose"
        "colored-man-pages"
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
        "dash"
        "macos"
      ];
      extraConfig = ''
        zstyle ':omz:update' mode reminder
      '';
    };
  };
}
