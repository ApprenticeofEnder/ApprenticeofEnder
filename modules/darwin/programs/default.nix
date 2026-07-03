let
  disallowedFiles = [
    # keep-sorted start
    "default.nix"
    # keep-sorted end
  ];
  filterFiles = filename: !(builtins.elem filename disallowedFiles);
in {
  imports = with builtins;
    map (fn: ./${fn}) (filter filterFiles (attrNames (readDir ./.)));
}
