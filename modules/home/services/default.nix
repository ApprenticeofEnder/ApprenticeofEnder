# A module that automatically imports everything else in the parent folder.
{
  imports = with builtins;
    map (fn: ./${fn}) (filter (fn: fn != "default.nix" && fn != "ntfy.bak.nix") (attrNames (readDir ./.)));
}
