# A module that automatically imports everything else in the parent folder.
let
  disallowedFiles = [
    # keep-sorted start
    "default.nix"
    "drivers.json"
    "lib"
    "targets.nix"
    # keep-sorted end
  ];
  filterFiles = filename: !(builtins.elem filename disallowedFiles);
in {
  imports = with builtins;
    map (fn: ./${fn}) (filter filterFiles (attrNames (readDir ./.)));
}
