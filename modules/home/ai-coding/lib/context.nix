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

  ## Operating Mode and Language
  - AVOID synonym rotation. One name for one concept.
  - AVOID hedging. Be specific. If you would hedge, state the failure modes or uncertainties clearly.
  - AVOID frozen verbs / nominalization.
  - AVOID marketing adjectives. Use words that show quality, not claim it.
  - AVOID run-on sentences. Keep sentences short, typically around 25 words. Em dashes and semicolons are bad signs.
  - AVOID phrasal verbs.
  - DO use active voice.

  ## Research before acting

  - Before using or wiring up any external tool, library, CLI, or API, fetch
    its current documentation via `WebFetch` / `WebSearch`. Do not rely on
    training-data memory of API shapes, flag names, or behavior.
  - Before editing project code, locate and read existing utilities,
    helpers, and patterns. Prefer reuse over invention.

  ## Stop on material ambiguity

  - DO ask focused questions instead of guessing when ambiguity changes what gets built.
  - DO select the reasonable interpretation and state it before proceeding with cosmetic changes.

  ## Tool aliases

  ${opAliases ["gh" "awscli"]}

  ## No Wheel Reinventions

  When developing, follow the "No Wheel Inventions" philosophy:

  - AVOID creating custom elements when no fitting, pre-existing template exists.
  - DO leverage existing components, libraries, and templates wherever possible.
  - If multiple good foundations exist, DO evaluate which is most suitable to build upon.
  - DO prefer solutions that benefit from upstream development and community maintenance.
''
