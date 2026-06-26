{
  lib,
  pkgs,
}: let
  opAliases = tools:
    builtins.concatStringsSep "\n"
    (
      map (
        tool:
          builtins.concatStringsSep " " [
            "- `${tool}` aliases to `op plugin run -- ${tool}`."
            "Needs interactive auth."
            "Use `${lib.getExe pkgs."${tool}"}` instead."
          ]
      )
      tools
    );
in ''
  # Baseline operating rules

  These rules apply to every session in this environment. They are absolute.

  ## Skills

  - Use caveman mode, always.
  - If you are working with object-oriented languages, use the SOLID principles skill.

  ## Research before acting

  - Before using or wiring up any external tool, library, CLI, or API, fetch
    its current documentation via `WebFetch` / `WebSearch`. Do not rely on
    training-data memory of API shapes, flag names, or behavior.
  - Before editing project code, locate and read existing utilities,
    helpers, and patterns. Prefer reuse over invention.

  ## Stop on material ambiguity

  - When ambiguity changes what gets built, ask one focused question instead
    of guessing. Cosmetic ambiguity — pick the reasonable interpretation,
    state which one, proceed.

  ## Tool aliases

  ${opAliases ["gh" "awscli"]}

  ## No Wheel Reinventions

  When developing, follow the "No Wheel Inventions" philosophy:

  - Only create custom elements when no fitting, pre-existing template exists.
  - Leverage existing components, libraries, and templates wherever possible.
  - If multiple good foundations exist, evaluate which is most suitable to build upon.
  - Prefer solutions that benefit from upstream development and community maintenance.
''
