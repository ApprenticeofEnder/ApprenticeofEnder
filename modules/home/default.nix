# A module that automatically imports everything else in the parent folder.
let
  filterFiles = filename: (
    filename
    != "default.nix"
    && filename != "targets.nix"
    && filename != "drivers.json"
  );
in {
  imports = with builtins;
    map (fn: ./${fn}) (filter filterFiles (attrNames (readDir ./.)));
}
