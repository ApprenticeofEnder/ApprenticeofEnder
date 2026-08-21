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
          version = "580.173.02";
          sha256 = "sha256-jY65AB4FqaimY9PV0wT+tk7yhE7hhczf2VJ4aCD0bhs=";
        };
      };
    };

    home.packages = with pkgs; [
      openlibm # needed for nvtop? I think?
    ];
  })
]
