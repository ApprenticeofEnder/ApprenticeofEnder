# A module that automatically imports everything else in the parent folder.
{ pkgs, lib, ... }: lib.mkIf pkgs.stdenv.isLinux {
  imports =
    with builtins;
    map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.)));
}
