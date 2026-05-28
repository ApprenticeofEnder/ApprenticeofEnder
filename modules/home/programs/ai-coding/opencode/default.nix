{pkgs, ...}: let
  aiCodingLib = import ../lib.nix {inherit pkgs;};
  inherit (aiCodingLib) mkAgents;
  inherit (aiCodingLib) mcpToolList;
  inherit (aiCodingLib) buildAccessList;
  fileReadList = buildAccessList {
    deny = [
      "*.env"
      "*.env.*"
      "*.vars"
      "*.secrets"
      "~/.aws/"
    ];
    allow = [
      "*"
      "*.env.example"
    ];
  };

  agents = builtins.listToAttrs (
    map (name: {
      name = name;
      value = (mkAgents name).opencode;
    }) ["terraform-engineer"]
  );
in {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    tui = {
      theme = "nord";
    };

    skills = ../skills;

    settings = {
      autoshare = false;
      autoupdate = false;

      # disabled_providers= ["openai" "gemini"];
      # instructions = ["CONTRIBUTING.md" "docs/guidelines.md" ".cursor/rules/*.md"];
      #   model = "anthropic/claude-sonnet-4-20250514";
      #   model= "{env:OPENCODE_MODEL}";
      # };
      agent = agents;

      permission =
        {
          read = fileReadList;
          edit = "ask";
          bash =
            {"*" = "ask";}
            // buildAccessList {
              deny = [
                "curl *"
                "wget *"
                "nc *"
                "git push *"
              ];
              allow = [
                "git status"
                "git diff"
              ];
            };
          webfetch = "allow";
          websearch = "ask";
          grep = fileReadList;
          glob = fileReadList;

          skill = buildAccessList {
            allow = ["caveman"];
          };
        }
        // (
          let
            serena_mcp = {
              name = "serena";
              style = "opencode";
            };
          in
            buildAccessList {
              allow = mcpToolList serena_mcp [
                "edit_memory"
                "find_*"
                "get_*"
                "initial_*"
                "list_*"
                "onboarding"
                "read_memory"
                "rename_memory"
                "write_memory"
              ];
              ask = mcpToolList serena_mcp ["*"];
            }
        );
    };
  };
}
