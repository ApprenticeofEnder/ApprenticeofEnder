{
  lib,
  pkgs,
  ...
}: let
  ai_coding_lib = import ../lib {inherit lib;};
  inherit (ai_coding_lib) mcpToolList;
  inherit (ai_coding_lib) mkOpencodePermissionList;
  inherit (ai_coding_lib) sensitive_files;
  inherit (ai_coding_lib) lockfiles;
  inherit (ai_coding_lib) global_bash;
  inherit (ai_coding_lib) opencode_serena_tools;
  context = import ../lib/context.nix {inherit lib pkgs;};

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
      diff_style = "stacked";
    };

    skills = ../skills;

    context =
      (builtins.readFile ../baseline-rules.md)
      + context
      + ''

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
          mkOpencodePermissionList {
            allow = opencode_serena_tools.basic;
            ask = mcpToolList.opencode {
              name = "serena";
              tools = ["*"];
            };
          }
        );
    };
  };
}
