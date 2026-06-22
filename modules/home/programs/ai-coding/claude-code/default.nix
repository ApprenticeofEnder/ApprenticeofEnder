{
  lib,
  config,
  pkgs,
  ...
}: let
  ai_coding_lib = import ../lib {inherit lib;};
  # keep-sorted start
  inherit (ai_coding_lib) claude_serena_tools;
  inherit (ai_coding_lib) claude_tools;
  inherit (ai_coding_lib) global_bash;
  inherit (ai_coding_lib) lockfiles;
  inherit (ai_coding_lib) mkClaudePermissionList;
  inherit (ai_coding_lib) sensitive_files;
  # keep-sorted end

  context = import ../lib/context.nix {inherit lib pkgs;};
in {
  home.shellAliases = {
    claude = lib.removeSuffix "\n" ''CC_SYSTEM_PROMPT=$(serena prompts print-cc-system-prompt-override) ${lib.getExe config.programs.claude-code.finalPackage} --system-prompt="$CC_SYSTEM_PROMPT"'';
  };

  home.file = {
    ".claude/hooks/clamp-bash-timeout.sh" = {
      source = ./hooks/clamp-bash-timeout.sh;
      executable = true;
    };

    ".claude/hooks/force-skill.sh" = {
      source = ./hooks/force-skill.sh;
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
    context = context;
    skills = builtins.listToAttrs (map (skill: {
        name = skill;
        value = ../skills/${skill}/SKILL.md;
      }) [
        # keep-sorted start
        "1password"
        "agent-canvas-usage"
        "caveman"
        "component-search"
        "dependency-audit"
        "deslop"
        "dotnet-code-quality"
        "dotnet-dev-guidelines"
        "fleet-deploy"
        "review-and-ship"
        "tanstack"
        "template-check"
        "thermo-code-quality"
        "verify-this"
        # keep-sorted end
      ]);
    # agents = agents;

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
          claude_serena_tools.basic
        ];
        # ask = [];
        deny = lib.concatLists [
          (mkClaudePermissionList claude_tools.read sensitive_files.claude)
          (mkClaudePermissionList claude_tools.edit (sensitive_files.claude ++ lockfiles.claude))
          (mkClaudePermissionList claude_tools.bash global_bash.deny)
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
            ];
          }
        ];
        UserPromptSubmit = [
          {
            hooks = [
              {
                type = "command";
                command = "~/.claude/hooks/force-skill.sh";
              }
            ];
          }
        ];
        SubagentStart = [
          {
            matcher = "";
            hooks = [
              # {
              #   type = "command";
              #   command = "serena-hooks activate --client=claude-code";
              # }
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
