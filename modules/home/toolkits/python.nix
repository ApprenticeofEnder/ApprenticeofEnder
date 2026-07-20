{
  pkgs,
  lib,
  ...
}: let
  home-lib = import ../lib {inherit lib;};
  inherit (home-lib) vscode;
  inherit (vscode) mkVsCode;
  vscodeConfig = mkVsCode {
    extensions = with pkgs.vscode-extensions; [
      # keep-sorted start
      charliermarsh.ruff
      detachhead.basedpyright
      ms-python.python
      # keep-sorted end
    ];
  };

  python = with pkgs;
    if stdenv.isLinux
    then
      python313.withPackages (
        ps:
          with ps; [
            pygame
            zlib-ng
          ]
      )
    else python313;
in
  lib.mkMerge [
    vscodeConfig
    {
      home.packages = [
        python
      ];
      programs = {
        ruff = {
          enable = true;
          settings = {
            line-length = 80;
            indent-width = 4;

            lint = {
              select = [
                # pycodestyle
                "E"
                # Pyflakes
                "F"
                # pyupgrade
                "UP"
                # flake8-bugbear
                "B"
                # flake8-simplify
                "SIM"
                # isort
                "I"
                # fastapi
                "FAST"
              ];

              extend-select = ["E501"];

              isort.known-first-party = [
                # keep-sorted start
                "api"
                "app"
                "tests"
                # keep-sorted end
              ];

              dummy-variable-rgx = "^(_+|(_+[a-zA-Z0-9_]*[a-zA-Z0-9]+?))$";
            };

            format = {
              docstring-code-format = true;
              docstring-code-line-length = "dynamic";
            };
          };
        };
        uv = {
          enable = true;
          settings = {};
        };
      };
    }
  ]
