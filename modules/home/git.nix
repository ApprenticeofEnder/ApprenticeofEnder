{
  config,
  # lib,
  pkgs,
  nixosConfig,
  ...
}: let
  signer_pubkey = builtins.readFile ./programs/ssh/keys/github.pub;
  op-ssh-sign =
    if pkgs.stdenv.isDarwin
    then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else if nixosConfig != null
    then "${pkgs._1password-gui}/share/1password/op-ssh-sign"
    else "/opt/1Password/op-ssh-sign";
in {
  home.shellAliases = {
    g = "git";
    lg = "lazygit";
  };
  home.file.".ssh/allowed_signers".text = "* ${signer_pubkey}";

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
        gpg = {
          format = "ssh";
          ssh = {
            allowedSignersFile = "~/.ssh/allowed_signers";
            program = op-ssh-sign;
          };
        };
        commit.gpgsign = true;
        user = {
          name = config.me.fullname;
          email = config.me.email;
          signingkey = "${signer_pubkey}";
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
