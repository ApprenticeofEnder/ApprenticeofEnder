{
  lib,
  config,
  pkgs,
  ...
}: let
  ai_coding_lib = import ../lib {inherit lib;};
  # keep-sorted start
  inherit (ai_coding_lib) claude_tools;
  inherit (ai_coding_lib) collectLeafFiles;
  inherit (ai_coding_lib) global_bash;
  inherit (ai_coding_lib) lockfiles;
  inherit (ai_coding_lib) mcpToolSet;
  inherit (ai_coding_lib) mkClaudePermissionList;
  inherit (ai_coding_lib) sensitive_files;
  inherit (ai_coding_lib) serena_tools;
  # keep-sorted end

  context = import ../lib/context.nix {inherit lib pkgs;};

  skill_file_paths = collectLeafFiles ../skills "";

  skill_files = with builtins;
    listToAttrs (
      map (fn: {
        name = ".claude/skills/${fn}";
        value = {
          text = readFile (../skills + "/${fn}");
        };
      })
      skill_file_paths
    );

  mcp_tools = {
    serena = mcpToolSet {
      name = "serena";
      tools = {
        basic = serena_tools.basic;
        edit = serena_tools.edit;
      };
      home_manager = true;
      agent = "claude";
    };

    atlassian = mcpToolSet {
      name = "claude_ai_Atlassian";
      tools = {
        issues = [
          "getTransitionsForJiraIssue"
          "transitionIssue"
        ];
      };
      agent = "claude";
    };
  };
in {
  imports = [
    ./hooks
  ];
  home.shellAliases = {
    claude = lib.removeSuffix "\n" ''CC_SYSTEM_PROMPT=$(serena prompts print-cc-system-prompt-override) ${lib.getExe config.programs.claude-code.finalPackage} --system-prompt="$CC_SYSTEM_PROMPT"'';
  };

  home.file =
    skill_files
    // {
      ".claude/scripts/claude-hud-statusline.sh" = {
        source = ./scripts/claude-hud-statusline.sh;
        executable = true;
      };
    };

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    context = context;

    settings = {
      model = "sonnet";
      env = {
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = 1;
        GIT_EXTERNAL_DIFF = "difft";
      };
      enabledPlugins = {
        "claude-hud@claude-hud" = true;
      };

      statusLine = {
        type = "command";
        command = "~/.claude/scripts/claude-hud-statusline.sh";
      };
      permissions = {
        allow = lib.concatLists [
          (mkClaudePermissionList claude_tools.read [
            "*"
            "**/*.env.example"
          ])
          (mkClaudePermissionList claude_tools.bash [
            "git status"
            "git diff"
          ])
          mcp_tools.serena.basic
          mcp_tools.atlassian.issues
        ];
        # ask = [];
        deny = lib.concatLists [
          (mkClaudePermissionList claude_tools.read sensitive_files.claude)
          (mkClaudePermissionList claude_tools.edit (sensitive_files.claude ++ lockfiles.claude))
          (mkClaudePermissionList claude_tools.bash global_bash.deny)
        ];
      };
    };
  };
}
