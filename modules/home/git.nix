{
  config,
  pkgs,
  lib,
  ...
}: let
  signer_pubkey = lib.replaceStrings ["\n"] [""] (
    builtins.readFile ./programs/ssh/keys/github.pub
  );
  op-ssh-sign = config.op.ssh-sign;
in {
  home.shellAliases = {
    g = "git";
    lg = "lazygit";
  };
  home.file.".ssh/allowed_signers".text = "* ${signer_pubkey}";
  home.packages = with pkgs; [
    jujutsu
  ];

  xdg.configFile = {
    "jj/config.toml" = {
      text = ''
        [user]
        name = "${config.me.fullname}"
        email = "${config.me.email}"

        [ui]
        # Use Difftastic by default
        diff-formatter = ["difft", "--color=always", "$left", "$right"]
        editor = "nvim"

        [signing]
        behavior = "own"
        backend = "ssh"
        backends.ssh.allowed_signers = "~/.ssh/allowed_signers"
        backends.ssh.program = "${op-ssh-sign}"
        key = "${signer_pubkey}"
      '';
    };
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
          difft_prefix = "-c diff.external=difft";
        in {
          ga = "git add .";
          dl = "${difft_prefix} log -p --ext-diff";
          ds = "${difft_prefix} show --ext-diff";
          dft = "${difft_prefix} diff";
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
