{
  pkgs,
  lib,
  ...
}: let
  ai_coding_lib = import ../lib {inherit lib pkgs;};
  inherit (ai_coding_lib) collectLeafFiles;

  skill_file_paths = collectLeafFiles ../skills "";

  skill_files = with builtins;
    listToAttrs (
      map (fn: {
        name = ".cursor/skills/${fn}";
        value = {
          text = readFile (../skills + "/${fn}");
        };
      })
      skill_file_paths
    );
in {
  home.packages = with pkgs; [
    cursor-cli
  ];

  home.file = skill_files;
}
