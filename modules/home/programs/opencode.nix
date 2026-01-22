{pkgs-unstable, ...}: {
  programs.opencode = {
    enable = true;
    package = pkgs-unstable.opencode;
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
            "mcp/aws-terraform:latest"
          ];
          environment = {
            FASTMCP_LOG_LEVEL = "ERROR";
          };
        };
        # TODO: Investigate these MCP servers:
        # https://github.com/augmnt/augments-mcp-server
        # https://github.com/securityfortech/secops-mcp
        # https://github.com/exoticknight/mcp-file-merger
        # https://github.com/semgrep/semgrep
        # https://github.com/8b-is/smart-tree
        # https://github.com/CodeGraphContext/CodeGraphContext
        # https://github.com/trilogy-group/aws-pricing-mcp
        # https://github.com/Flux159/mcp-server-kubernetes
        # https://github.com/oraios/serena
      };
      # mcp = {
      #   my-local-mcp-server = {
      #     enabled = true;
      #     type = "local";
      #     command = [
      #       "bun"
      #       "x"
      #       "my-mcp-command"
      #     ];
      #     environment = {
      #       MY_ENV_VAR = "my_env_var_value";
      #     };
      #   };
      # };

      provider = {
        ollama-ender = {
          npm = "@ai-sdk/openai-compatible";
          name = "ollama@ender-raptor";
          options = {
            "baseURL" = "http://localhost:11434/v1";
          };
          models = {
            "gpt-oss:20b" = {
              name = "gpt-oss:20b";
            };
            "gpt-oss:120b" = {
              name = "gpt-oss:120b";
            };
            "phind-codellama:34b" = {
              name = "phind-codellama:34b";
            };
            "qwen2.5-coder:32b" = {
              name = "qwen2.5-coder:32b";
            };
            "qwen3-coder:30b" = {
              name = "qwen3-coder:30b";
            };
            "codellama:70b" = {
              name = "codellama:70b";
            };
          };
        };
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
