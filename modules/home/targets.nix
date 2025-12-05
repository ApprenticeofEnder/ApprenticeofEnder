{ pkgs, lib, ... }:

lib.mkMerge [
  { }
  (lib.mkIf pkgs.stdenv.isLinux {
    targets = {
      genericLinux = {
        gpu.nvidia.enable = true;
      };
    };

    home.packages = with pkgs; [
      openlibm # needed for nvtop? I think?
    ];
  })
]

