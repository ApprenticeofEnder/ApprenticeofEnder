{
  pkgs,
  lib,
  ...
}:
lib.mkMerge [
  {}
  (lib.mkIf pkgs.stdenv.isLinux {
    targets = {
      genericLinux = {
        enable = true;
        gpu.nvidia = {
          enable = true;
          version = "580.126.09";
          sha256 = "sha256-TKxT5I+K3/Zh1HyHiO0kBZokjJ/YCYzq/QiKSYmG7CY=";
        };
      };
    };

    home.packages = with pkgs; [
      openlibm # needed for nvtop? I think?
    ];
  })
]
