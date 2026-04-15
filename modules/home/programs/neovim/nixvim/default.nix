{...}: let
  # Recursively find leaf files under a directory, returning list of relative paths
  collectLeafFiles = with builtins;
    dir: prefix: let
      entries = readDir dir;
    in
      concatLists (
        attrValues (
          mapAttrs (
            name: type:
              if type == "directory"
              then collectLeafFiles (dir + "/${name}") "${prefix}${name}/"
              else ["${prefix}${name}"]
          )
          entries
        )
      );

  queryFiles = collectLeafFiles ./queries "";
in {
  programs.nixvim = {
    enable = true;

    globals = {
      mapleader = " ";
      maplocalleader = "\\";
    };

    extraFiles = with builtins;
      listToAttrs (
        map (fn: {
          name = "queries/${fn}";
          value = {
            enable = true;
            text = readFile (./queries + "/${fn}");
          };
        })
        queryFiles
      );

    imports = [
      ./plugins
      ./autocmds.nix
      ./lsp.nix
      ./options.nix
      ./mappings.nix
    ];

    colorschemes = {
      nord.enable = true;
    };

    # extraConfigLua = ''/* hover.lua inline */ '';
  };
}
