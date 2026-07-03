{
  globset,
  lib,
}: {
  getNixImports = {
    root,
    exclude ? [],
  }: let
    patterns =
      [
        "*.nix"
        "*/default.nix"
        "!default.nix"
      ]
      ++ (
        map (pattern: "!${pattern}") exclude
      );
  in
    lib.fileset.toList (
      globset.lib.globs root patterns
    );
}
