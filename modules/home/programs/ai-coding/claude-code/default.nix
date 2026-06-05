{
  config,
  lib,
  ...
}: let
  ai_coding_lib = import ../lib {inherit lib;};
  inherit (ai_coding_lib) mkClaudePermissionList;
  inherit (ai_coding_lib) mcpToolList;
  inherit (ai_coding_lib) global_bash;
  inherit (ai_coding_lib) sensitive_files;
  inherit (ai_coding_lib) lockfiles;
  inherit (ai_coding_lib) serena_tools;
in {
  home.shellAliases = {
    claude = lib.removeSuffix "\n" ''CC_SYSTEM_PROMPT=$(serena prompts print-cc-system-prompt-override) ${lib.getExe config.programs.claude-code.finalPackage} --system-prompt="$CC_SYSTEM_PROMPT"'';
  };

  home.file = {
    ".claude/hooks/clamp-bash-timeout.sh" = {
      source = ./hooks/clamp-bash-timeout.sh;
      executable = true;
    };

    ".claude/skills/fleet-deploy/missive.md" = {
      source = ../skills/fleet-deploy/missive.md;
    };

    ".claude/scripts/claude-hud-statusline.sh" = {
      source = ./scripts/claude-hud-statusline.sh;
      executable = true;
    };
  };

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    context = ../baseline-rules.md;
    skills = builtins.listToAttrs (map (skill: {
        name = skill;
        value = ../skills/${skill}/SKILL.md;
      }) [
        # keep-sorted start
        "1password"
        "agent-canvas-usage"
        "caveman"
        "deslop"
        "dotnet-code-quality"
        "dotnet-dev-guidelines"
        "fleet-deploy"
        "review-and-ship"
        "tanstack"
        "thermo-code-quality"
        "verify-this"
        # keep-sorted end
      ]);
    # agents = agents;

    settings = {
      model = "sonnet";
      env = {
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = 1;
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
          (mkClaudePermissionList ["Read" "Grep" "Glob"] [
            "*"
            "**/*.env.example"
          ])
          (mkClaudePermissionList ["Bash"] [
            "git status"
            "git diff"
          ])
          (mcpToolList.claude {
            name = "serena";
            tools = serena_tools.basic;
          })
        ];
        # ask = [];
        deny = lib.concatLists [
          (mkClaudePermissionList ["Read" "Grep" "Glob"] sensitive_files.claude)
          (mkClaudePermissionList ["Write" "Edit"] (sensitive_files.claude ++ lockfiles.claude))
          (mkClaudePermissionList ["Bash"] global_bash.deny)
        ];
      };
      hooks = {
        PreToolUse = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "serena-hooks remind --client=claude-code";
              }
            ];
          }
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = "~/.claude/hooks/clamp-bash-timeout.sh";
              }
            ];
          }
        ];
        SessionStart = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "serena-hooks activate --client=claude-code";
              }
              {
                type = "command";
                command = "echo 'use caveman'";
              }
            ];
          }
        ];
        SessionEnd = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "serena-hooks cleanup --client=claude-code";
              }
            ];
          }
        ];
      };
    };
  };
}
