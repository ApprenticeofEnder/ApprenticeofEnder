{
  pkgs,
  lib,
  ...
}: let
  aiCodingLib = import ../lib.nix {inherit pkgs;};
  inherit (aiCodingLib) mkAgents;
  # inherit (aiCodingLib) mcpToolList;

  agents = builtins.listToAttrs (
    map (name: {
      name = name;
      value = (mkAgents name).claude;
    }) ["terraform-engineer"]
  );
in {
  home.shellAliases = {
    claude = lib.removeSuffix "\n" ''CC_SYSTEM_PROMPT=$(serena prompts print-cc-system-prompt-override) ${lib.getExe pkgs.claude-code} --system-prompt="$CC_SYSTEM_PROMPT"'';
  };
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    skills = {
      caveman = ../skills/caveman/SKILL.md;
    };
    agents = agents;

    settings = {
      env = {
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = 1;
      };
    };
  };
}
