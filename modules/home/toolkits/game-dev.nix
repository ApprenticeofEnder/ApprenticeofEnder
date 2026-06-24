{pkgs, ...}: {
  home.packages = with pkgs; [
    godot # game engine
  ];

  programs = let
    extensions = with pkgs.vscode-extensions; [
      geequlim.godot-tools
    ];
  in {
    vscode = {
      profiles = {
        default = {
          inherit extensions;
        };
      };
    };
    vscodium = {
      profiles = {
        default = {
          inherit extensions;
        };
      };
    };
  };
}
