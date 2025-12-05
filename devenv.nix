{ pkgs, lib, config, inputs, ... }:

let
  pushCache = "rbabaev";
in
{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  name = "Home Base";

  cachix = {
    pull = [
      "cachix"
      "oxalica"
      "rbabaev"
      "nixpkgs"
      "mfarabi"
      "nix-darwin"
      "nix-community"
      "pre-commit-hooks"
    ];
  };

  # https://devenv.sh/packages/
  packages = with pkgs; [
    just
    nixd
    cachix
    nix-top
    pulumi-esc
  ];

  # https://devenv.sh/languages/
  # languages.rust.enable = true;

  # https://devenv.sh/processes/
  # processes.dev.exec = "${lib.getExe pkgs.watchexec} -n -- ls -la";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  scripts = {
    upcache = {
      exec = ''
        set -euxo pipefail

        nix path-info --all | cachix push ${pushCache}
      '';
    };
  };

  # https://devenv.sh/basics/
  enterShell = ''
    hello         # Run scripts directly
    git --version # Use packages
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
