{
  lib,
  pkgs,
}: ''
  # Baseline operating rules

  These rules apply to every session in this environment. They are absolute.

  ## Skills

  - Use caveman mode, always.

  ## Research before acting

  - Before using or wiring up any external tool, library, CLI, or API, fetch
    its current documentation via `WebFetch` / `WebSearch`. Do not rely on
    training-data memory of API shapes, flag names, or behavior.
  - Before editing project code, locate and read existing utilities,
    helpers, and patterns. Prefer reuse over invention.

  ## Tool aliases

  - `gh` aliases to `op plugin run -- gh`. Needs interactive auth. Use `${lib.getExe pkgs.gh}` instead.
''
