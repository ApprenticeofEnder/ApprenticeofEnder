{...}: {
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
