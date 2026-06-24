{lib, ...}: rec {
  toYaml = data: lib.generators.toYAML {} data;

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
}
