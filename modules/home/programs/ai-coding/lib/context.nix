{
  lib,
  pkgs,
}: ''

  ## Tool aliases

  - `gh` aliases to `op plugin run -- gh`. Needs interactive auth. Use `${lib.getExe pkgs.gh}` instead.
''
