{
  lib,
  pkgs,
  config,
  ...
}: let
  name = "Robert Babaev";
  pushCache = "rbabaev";
in {
  # https://devenv.sh/basics/
  name = "Home Base";

  infoSections = {
    authors = [
      name
    ];
  };

  cachix = {
    pull = [
      "nix-darwin"
      "pre-commit-hooks"
    ];
  };

  # https://devenv.sh/packages/
  packages = with pkgs; [
    git
    vale
    just
    nixd
    stow
    nix-top
    prettier
    jinja2-cli
    pulumi-esc
  ];

  scripts = {
    upcache = {
      exec = ''
        set -euxo pipefail
        nix-collect-garbage -d
        devenv gc
        nix path-info --all | cachix push --verbose ${pushCache}
      '';
      description = "Clean garbage and update Cachix cache";
    };
    generate-readme = {
      exec = ''
        set -euxo pipefail
        cd ${config.devenv.root}/templates
        jinja2 README.j2.md readme.json > README.md
        prettier README.md
      '';
    };
    fetch-nvidia-drivers = let
      sd = lib.getExe pkgs.sd;
      rg = lib.getExe pkgs.ripgrep;
      targetPath = "${config.devenv.root}/modules/home/targets.nix";
    in {
      exec = ''
        NEW_DRIVER_VERSION="$(modinfo nvidia | ${rg} "^version" | ${sd} "version:\s+" "")"
        echo "New NVIDIA driver version is $NEW_DRIVER_VERSION"
        NEW_DRIVER_HASH="$(nix store prefetch-file \
          --json \
          "https://download.nvidia.com/XFree86/Linux-x86_64/$NEW_DRIVER_VERSION/NVIDIA-Linux-x86_64-$NEW_DRIVER_VERSION.run" |
          jq -r '.hash'
          )"
        echo "SHA256 is $NEW_DRIVER_HASH"

        sd 'version = "[0-9.]+"' "version = \"$NEW_DRIVER_VERSION\"" ${targetPath}
        sd 'sha256 = "sha256-[A-Za-z0-9/+=]+"' "sha256 = \"$NEW_DRIVER_HASH\"" ${targetPath}
      '';
    };
    dotfiles = {
      exec = ''
        set -euxo pipefail
        cd ${config.devenv.root}/dotfiles
        links=(
          starship
          nvim
        )
        for link in "''${links[@]}"
        do
            stow $link --adopt -t ~
        done
      '';
      description = "Load dotfiles";
    };
  };

  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
    esc version | grep --color=auto "${pkgs.pulumi-esc.version}"
  '';

  git-hooks.hooks = {
    alejandra.enable = true;
    deadnix.enable = true;
    vale.enable = true;
    shellcheck = {
      enable = true;
      excludes = [".zsh$"];
    };
    upcache = {
      entry = "upcache";
      enable = false;
      stages = [
        "pre-push"
      ];
    };
    keep-sorted.enable = true;
    convco.enable = true;
  };
}
