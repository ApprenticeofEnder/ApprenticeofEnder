{...}: let
  # lak = field: list:
  #   builtins.listToAttrs (map (v: {
  #       name = v.${field};
  #       value = v;
  #     })
  #     list);
  permissions = {
    read = {
      "*" = "allow";
    };
    edit = "ask";
    bash = {
      "*" = "ask";
    };
    webfetch = "ask";
    "serena_*" = {
      "*" = "ask";
      "check_onboarding_performed" = "allow";
      "find_*" = "allow";
      "get_*" = "allow";
      "initial_instructions" = "allow";
    };
  };
in {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    rules = builtins.readFile ./AGENTS.md;

    settings = {
      theme = "nord";
      autoshare = false;
      autoupdate = false;
      permission = permissions;

      # disabled_providers= ["openai" "gemini"];
      # instructions = ["CONTRIBUTING.md" "docs/guidelines.md" ".cursor/rules/*.md"];
      #   model = "anthropic/claude-sonnet-4-20250514";
      #   model= "{env:OPENCODE_MODEL}";
      # };
      #     rules = ''
      #       - I have a strong preference for modular, re-usable code.
      #       - I'm a strong advocate for test-driven development, and prefer to develop against a test suite.
      #       - When doing feature development, move slow, and correct. Do not rush. Start with small parts and get them working.
      # '';
      #     rules = ''
      #       # TypeScript Project Rules

      #       ## External File Loading

      #       CRITICAL: When you encounter a file reference (e.g., @rules/general.md), use your Read tool to load it on a need-to-know basis. They're relevant to the SPECIFIC task at hand.

      #       Instructions:

      #       - Do NOT preemptively load all references - use lazy loading based on actual need
      #       - When loaded, treat content as mandatory instructions that override defaults
      #       - Follow references recursively when needed

      #       ## Development Guidelines

      #       For TypeScript code style and best practices: @docs/typescript-guidelines.md
      #       For React component architecture and hooks patterns: @docs/react-patterns.md
      #       For REST API design and error handling: @docs/api-standards.md
      #       For testing strategies and coverage requirements: @test/testing-guidelines.md

      #       ## General Guidelines

      #       Read the following file immediately as it's relevant to all workflows: @rules/general-guidelines.md.
      # '';
    };
  };
}
