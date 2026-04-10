{
  lib,
  pkgs,
  config,
  ...
}: let
  name = "Robert Babaev";
  domain = "robertbabaev.tech";
  pushCache = "rbabaev";

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
    fetch-nvidia-drivers = let
      graphicsCardSeriesId = "120"; # GeForce RTX 30 series
      graphicsCardId = "965"; # RTX 3070 Ti
      osId = "12"; # Linux, 64-bit
      languageCode = "1033"; # en-US

      queryParameters = {
        func = "DriverManualLookup";
        psid = graphicsCardSeriesId;
        pfid = graphicsCardId;
        osID = osId;
        languageCode = languageCode;
        beta = "null";
        isWHQL = "0";
        dlType = "-1";
        dch = "0";
        upCRD = "null";
        qnf = "0";
        ctk = "null";
        sort1 = "1";
        numberOfResults = "1";
      };

      makeQueryString = parameter: let
        parameterValue = queryParameters."${parameter}";
      in "${parameter}=${parameterValue}";

      queryString = lib.strings.join "&" (map makeQueryString (builtins.attrNames queryParameters));

      driverFilePath = "${config.devenv.root}/modules/home/drivers.json";
    in {
      exec = ''
        NVIDIA_URL="https://gfwsl.geforce.com/services_toolkit/services/com/nvidia/services/AjaxDriverService.php?${queryString}"
        NEW_DRIVER_VERSION="$(curl "$NVIDIA_URL" | jq -r '.IDS[0].downloadInfo.DisplayVersion')"
        echo "New NVIDIA driver version is $NEW_DRIVER_VERSION"
        NEW_DRIVER_HASH="$(nix store prefetch-file \
          --json \
          "https://download.nvidia.com/XFree86/Linux-x86_64/$NEW_DRIVER_VERSION/NVIDIA-Linux-x86_64-$NEW_DRIVER_VERSION.run" |
          jq -r '.hash'
          )"
        echo "SHA256 is $NEW_DRIVER_HASH"

        jq -n \
          --arg "version" "$NEW_DRIVER_VERSION" \
          --arg "sha256" "$NEW_DRIVER_HASH" \
          '$ARGS.named' > ${driverFilePath}
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
