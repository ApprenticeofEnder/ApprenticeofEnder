{...}: {
  imports = [
    ./agents
    ./permissions.nix
  ];
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    settings = {
      theme = "nord";
      autoshare = false;
      autoupdate = false;

      # disabled_providers= ["openai" "gemini"];
      # instructions = ["CONTRIBUTING.md" "docs/guidelines.md" ".cursor/rules/*.md"];
      #   model = "anthropic/claude-sonnet-4-20250514";
      #   model= "{env:OPENCODE_MODEL}";
      # };
    };
  };
}
