{ pkgs, lib, config, inputs, ... }:
let
  pushCache = "rbabaev";

  devicon = icon:
    "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/${icon}/${icon}-original.svg";
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
    jinja2-cli
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

  files = {
    "templates/readme.json".json = {
      pfp_image = "https://robertbabaev.tech/images/PFP_V2.jpg";
      name = "Robert Babaev";
      linkedin = "https://www.linkedin.com/in/robertbabaev2001";
      website = "https://robertbabaev.tech";
      languages = {
        favourites = [
          {
            image = "https://cdn.simpleicons.org/rust/FFFFFF";
            href = "https://rust-lang.org/";
            alt = "Rust";
          }
          {
            image = devicon "python";
            href = "https://www.python.org";
            alt = "Python";
          }
          {
            image = devicon "typescript";
            href = "https://typescriptlang.org";
            alt = "TypeScript";
          }
          {
            image = devicon "nixos";
            href = "https://nixos.org";
            alt = "Nix";
          }
        ];
        actively_using = [
          {
            image = devicon "csharp";
            href = "https://learn.microsoft.com/en-us/dotnet/csharp/";
            alt = "C#";
          }
          {
            image = devicon "dart";
            href = "https://dart.dev";
            alt = "Dart";
          }
        ];
        previous = [
          # Java
          # Golang
        ];
      };
      frameworks = {
        favourites = [
          # FastAPI
          # Loco.rs
          # Svelte
        ];
        actively_using = [{
          image = devicon "flutter";
          href = "https://flutter.dev";
          alt = "Flutter";
        }
          # React
          # Django
        ];
        previous = [ ];
      };
      tools = {
        favourites = [

        ];
        actively_using = [

        ];
        previous = [

        ];
      };
    };
  };

  scripts = {
    upcache = {
      exec = ''
        set -euxo pipefail

        nix path-info --all | cachix push ${pushCache}
      '';
    };
    generate-readme = {
      exec = ''
        set -euxo pipefail
        cd ${config.devenv.root}/templates
        jinja2 README.j2.md readme.json > README.md
      '';
    };
  };

  # https://devenv.sh/basics/
  enterShell = ''
    hello         # Run scripts directly
    git --version # Use packages
  '';

  # https://devenv.sh/tasks/
  tasks = {
    "readme:generate".exec = config.scripts.generate-readme.exec;
    "readme:generate".after = [ "devenv:enterShell" ];
  };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
