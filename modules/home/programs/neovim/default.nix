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
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
  programs.nixvim = {
    enable = true;
    nixpkgs.config.allowUnfree = true;

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
      # keep-sorted start
      ./autocmds.nix
      ./filetypes.nix
      ./lsp.nix
      ./mappings.nix
      ./options.nix
      ./plugins
      # keep-sorted end
    ];

    colorschemes = {
      nord.enable = true;
    };

    # extraConfigLua = ''/* hover.lua inline */ '';
  };
}
