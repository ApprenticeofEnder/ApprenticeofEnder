{
  pkgs-unstable,
  config,
  ...
}: {
  programs.opencode = {
    enable = true;
    package = pkgs-unstable.opencode;

    rules = ''
      # General Rules

      - Use modular, reusable code as much as possible.
      - When doing feature development, move slow and start small. Get things working correctly before moving on.
      - Use good security practices. Follow security principles well, and think about potential security implications with each change as relevant.

      # Never Nesting

      Use the "never nester" approach wherever feasible. This means:

      1. Do not nest more than three layers deep.
      2. Use guard clauses.
      3. If you find yourself nesting 2 or 3 layers deep, try to extract the code to a separate function.
    '';

    settings = {
      # theme = "system";
      autoshare = false;
      autoupdate = false;
      permission = {
        edit = "ask";
        bash = "ask";
        webfetch = "ask";
      };
      mcp = {
        hashicorp-terraform = {
          enabled = true;
          type = "local";
          command = [
            "docker"
            "run"
            "--rm"
            "--interactive"
            "--name"
            "terraform-mcp"
            "hashicorp/terraform-mcp-server:latest"
          ];
        };
        aws-terraform = {
          enabled = true;
          type = "local";
          command = [
            "docker"
            "run"
            "--rm"
            "--interactive"
            "--name"
            "aws-terraform-mcp"
            "mcp/aws-terraform:latest"
          ];
          environment = {
            FASTMCP_LOG_LEVEL = "ERROR";
          };
        };
        semgrep = {
          enabled = true;
          type = "local";
          command = [
            "docker"
            "run"
            "--rm"
            "--interactive"
            "-v"
            "${config.home.homeDirectory}/Documents/Projects:/projects:ro"
            "--name"
            "semgrep-mcp"
            "semgrep/semgrep"
            "semgrep"
            "mcp"
            "-t"
            "stdio"
          ];
        };
        # TODO: Investigate these MCP servers:
        # https://github.com/augmnt/augments-mcp-server
        # https://github.com/securityfortech/secops-mcp
        # https://github.com/exoticknight/mcp-file-merger
        # https://github.com/8b-is/smart-tree
        # https://github.com/CodeGraphContext/CodeGraphContext
        # https://github.com/trilogy-group/aws-pricing-mcp
        # https://github.com/Flux159/mcp-server-kubernetes
        # https://github.com/oraios/serena
      };

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
