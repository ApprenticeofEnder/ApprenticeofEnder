{
  config,
  lib,
  pkgs,
  nixosConfig,
  ...
}: let
  signer_pubkey = builtins.readFile /home/${config.me.username}/.ssh/github.pub;
in
  lib.mkMerge [
    {
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
              ssh.allowedSignersFile = "~/.ssh/allowed_signers";
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
    (lib.mkIf pkgs.stdenv.isDarwin {
      programs.git.settings = {
        gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
    })
    (lib.mkIf (pkgs.stdenv.isLinux && nixosConfig == null) {
      programs.git.settings = {
        gpg.ssh.program = "/opt/1Password/op-ssh-sign";
      };
    })
  ]
