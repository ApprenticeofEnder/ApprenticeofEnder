{ pkgs, lib, ... }: {
  targets = {
    genericLinux = lib.mkIf pkgs.stdenv.isLinux {
      gpu.nvidia.enable = true;
    };
  };

  home.packages = with pkgs; [
    openlibm # needed for nvtop? I think?
  ];
}
