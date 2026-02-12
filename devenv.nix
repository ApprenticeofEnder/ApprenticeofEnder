{
  pkgs,
  config,
  ...
}: let
  name = "Robert Babaev";
  domain = "robertbabaev.tech";
  pushCache = "rbabaev";

  nvidiaDriverVersion = "580.126.09";

  devicon = icon: "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/${icon}/${icon}-original.svg";
in {
  # https://devenv.sh/basics/
  name = "Home Base";

  cachix = {
    pull = [
      "cachix"
      "mfarabi"
      "nixpkgs"
      "oxalica"
      "rbabaev"
      "nix-darwin"
      "nix-community"
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

  files = {
    "templates/readme.json".json = {
      pfp_image = "https://robertbabaev.tech/images/PFP_V2.jpg";
      name = name;
      linkedin = "https://www.linkedin.com/in/robertbabaev2001";
      website = "https://${domain}";
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
          {
            image = devicon "go";
            href = "https://go.dev";
            alt = "Go";
          }
        ];
        previous = [
          {
            image = devicon "java";
            href = "https://www.java.com/en/";
            alt = "Java";
          }
        ];
      };
      frameworks = {
        favourites = [
          {
            image = devicon "fastapi";
            href = "https://fastapi.tiangolo.com";
            alt = "FastAPI";
          }
          {
            image = devicon "svelte";
            href = "https://svelte.dev";
            alt = "Svelte";
          }
          # Loco.rs
        ];
        actively_using = [
          {
            image = devicon "flutter";
            href = "https://flutter.dev";
            alt = "Flutter";
          }
          {
            image = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/django/django-plain.svg";
            href = "https://djangoproject.com";
            alt = "Django";
          }
          {
            image = devicon "react";
            href = "https://react.dev";
            alt = "React";
          }
        ];
        previous = [
          {
            image = devicon "angular";
            href = "https://angular.dev";
            alt = "Angular";
          }
        ];
      };
      tools = {
        favourites = [
          {
            image = devicon "terraform";
            href = "https://developer.hashicorp.com/terraform";
            alt = "Terraform";
          }
          {
            image = devicon "pulumi";
            href = "https://www.pulumi.com";
            alt = "Pulumi";
          }
          {
            image = "https://raw.githubusercontent.com/cachix/devenv/36807c727e743e7a00999922e7f737a0cc4e05ac/logos/devenv-dark-bg.svg";
            href = "https://devenv.sh";
            alt = "Devenv";
          }
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
    nvidia-drivers = {
      exec = ''
        nix store prefetch-file \
          "https://download.nvidia.com/XFree86/Linux-x86_64/${nvidiaDriverVersion}/NVIDIA-Linux-x86_64-${nvidiaDriverVersion}.run"
      '';
      description = "Prefetch hash for Nvidia drivers";
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

  # https://devenv.sh/tasks/
  tasks = {
    "readme:generate" = {
      exec = config.scripts.generate-readme.exec;
      after = ["devenv:enterShell"];
      before = ["devenv:enterTest"];
      execIfModified = [
        "${config.git.root}/templates/README.j2.md"
        "${config.git.root}/templates/readme.json"
        "${config.git.root}/templates/techtable.j2.html"
      ];
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
    convco.enable = true;
  };
}
