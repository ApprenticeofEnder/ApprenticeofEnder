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
          version = "580.159.04";
          sha256 = "sha256-weZnYbCI0Xs632y2l53przi+JoTRArABoXbc+vq9yh4=";
        };
      };
    };

    home.packages = with pkgs; [
      openlibm # needed for nvtop? I think?
    ];
  })
]
