{ config, ... }:
{
  home.shellAliases = {
    g = "git";
    lg = "lazygit";
  };

  # https://nixos.asia/en/git
  programs = {
    git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        pull.rebase = false;
        user = {
          name = config.me.fullname;
          email = config.me.email;
        };
        alias = {
          ga = "git add .";
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
