{lib, ...}: let
  aiCodingLib = import ../lib {inherit lib;};
  inherit (aiCodingLib) mcpToolList;
  inherit (aiCodingLib) mkOpencodePermissionList;
  inherit (aiCodingLib) sensitive_files;
  inherit (aiCodingLib) lockfiles;
  inherit (aiCodingLib) global_bash;

  read_perms = mkOpencodePermissionList {
    deny = sensitive_files.opencode;
    allow = [
      "*"
      "*.env.example"
    ];
  };

  edit_perms = mkOpencodePermissionList {
    deny = sensitive_files.opencode ++ lockfiles.opencode;
    ask = ["*"];
  };

  bash_perms = mkOpencodePermissionList {
    deny = global_bash.deny;
    ask = global_bash.ask;
    allow = global_bash.allow;
  };
in {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    tui = {
      theme = "nord";
    };

    skills = ../skills;

    context = ''
      use caveman
    '';

    settings = {
      autoshare = false;
      autoupdate = false;

      # disabled_providers= ["openai" "gemini"];
      # instructions = ["CONTRIBUTING.md" "docs/guidelines.md" ".cursor/rules/*.md"];
      #   model = "anthropic/claude-sonnet-4-20250514";
      #   model= "{env:OPENCODE_MODEL}";
      # };

      # TODO: Make these deny by default
      permission =
        {
          read = read_perms;
          edit = edit_perms;
          bash = bash_perms;
          webfetch = "allow";
          websearch = "ask";
          grep = read_perms;
          glob = read_perms;

          skill = mkOpencodePermissionList {
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
            mkOpencodePermissionList {
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
