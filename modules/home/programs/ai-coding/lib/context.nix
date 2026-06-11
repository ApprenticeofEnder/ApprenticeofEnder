{
  lib,
  pkgs,
}: ''

  ## Tool aliases

  `gh` is an alias that runs through `op plugin run` and needs interactive
  authentication, so the bare `gh` command will not work non-interactively.
  Always invoke the real binary at `${lib.getExe pkgs.gh}` instead of `gh`.
''
