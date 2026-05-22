{
  pkgs,
  lib,
  ...
}:
lib.mkMerge [
  {}
  (lib.mkIf pkgs.stdenv.isDarwin {
    targets.darwin = {
      search = "DuckDuckGo";
    };
  })
  (lib.mkIf pkgs.stdenv.isLinux {
    targets = {
      genericLinux = {
        enable = true;
        gpu.nvidia = {
          enable = true;
          version = "580.159.03";
          sha256 = "sha256-MshdmbD2QMlQH2GzndrSCP0CiNAVxPvF/QQ1wHeD+nc=";
        };
      };
    };

    home.packages = with pkgs; [
      openlibm # needed for nvtop? I think?
    ];
  })
]
