{
  lib,
  pkgs,
  ...
}: {
  home = {
    activation.serena = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${lib.getExe pkgs.uv} tool install -p 3.13 serena-agent
    '';
    shellAliases = {
      claude = ''
        claude --system-prompt="$(serena prompts print-cc-system-prompt-override)"
      '';
    };
  };
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    agentsDir = ./agents;
    skills = {
      caveman = ./skills/caveman/SKILL.md;
    };

    settings = {
      env = {
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = 1;
      };
    };
  };
}
