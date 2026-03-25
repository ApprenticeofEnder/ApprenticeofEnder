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
        gpu.nvidia =
          {
            enable = true;
          }
          // builtins.fromJSON (
            builtins.readFile ./drivers.json
          );
      };
    };

    home.packages = with pkgs; [
      openlibm # needed for nvtop? I think?
    ];
  })
]
