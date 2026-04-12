{
  lib,
  pkgs,
  ...
}: {
  imports = [
    (
      lib.nixvim.plugins.mkNeovimPlugin {
        name = "nvchad-ui";
        defaultPackage = pkgs.vimPlugins.nvchad-ui;
        # ...
      }
    )

    (
      lib.nixvim.plugins.mkNeovimPlugin {
        name = "base46";
        defaultPackage = pkgs.vimPlugins.base46;
        # ...
      }
    )
  ];

  plugins = {
    base46.enable = true;
    nvchad-ui.enable = true;
  };
}
