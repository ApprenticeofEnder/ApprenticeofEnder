{
  pkgs,
  lib,
  ...
}:
lib.mkMerge [
  {}
  (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    targets.darwin = {
      search = "DuckDuckGo";
    };
  })
  (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    targets = {
      genericLinux = {
        enable = true;
        gpu.nvidia = {
          enable = true;
          version = "595.104.02";
          sha256 = "sha256-5CHCAuTHn1jDx/MWG75xRU67PYiTb4ggWg4yfNBMWco=";
        };
      };
    };

    home.packages = with pkgs; [
      openlibm # needed for nvtop? I think?
    ];
  })
]
