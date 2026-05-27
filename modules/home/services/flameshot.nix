{pkgs, ...}: let
  flameshot-pkgs =
    import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/05bbf675397d5366259409139039af8077d695ce.tar.gz";
      sha256 = "sha256-IE7PZn9bSjxI4/MugjAEx49oPoxu0uKXdfC+X7HcRuQ=";
    }) {
      system = pkgs.stdenv.hostPlatform.system;
    };
  flameshot = flameshot-pkgs.flameshot;
in {
  services.flameshot = {
    enable = true;
    package = flameshot;
  };
}
