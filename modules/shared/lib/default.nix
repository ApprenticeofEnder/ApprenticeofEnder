{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) globset;
in rec {
  filterString = {
    string,
    exclude,
  }:
    !(builtins.elem string exclude);

  filterNixFiles = {
    filename,
    exclude ? ["default.nix"],
  }:
    filterString {
      inherit exclude;
      string = filename;
    };

  getNixImports = {
    root,
    exclude ? [],
  }: let
    patterns =
      [
        "!default.nix"
        "*.nix"
        "*/default.nix"
      ]
      ++ (
        map (pattern: "!${pattern}") exclude
      );
  in
    lib.fileset.toList (
      globset.lib.globs root patterns
    );
}
