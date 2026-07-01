{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      godot # game engine
      gdtoolkit_4
    ];
  };

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
    nixvim = {
      lsp.servers.gdscript.enable = true;
      plugins.godot.enable = true;
    };
  };
}
