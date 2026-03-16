{config, ...}: {
  home.shellAliases = {
    g = "git";
    lg = "lazygit";
  };

  # https://nixos.asia/en/git
  programs = {
    difftastic = {
      enable = true;
      # git = {
      #   enable = true;
      #   diffToolMode = true;
      # };
    };
    git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        pull.rebase = false;
        user = {
          name = config.me.fullname;
          email = config.me.email;
        };
        alias = let
          prefix = "-c diff.external=difft";
        in {
          ga = "git add .";
          dl = "${prefix} log -p --ext-diff";
          ds = "${prefix} show --ext-diff";
          dft = "${prefix} diff";
        };
        # init.defaultBranch = "master";
        # pull.rebase = "false";
      };
      ignores = [
        "*~"
        "*.swp"
      ];
    };
  };
}
