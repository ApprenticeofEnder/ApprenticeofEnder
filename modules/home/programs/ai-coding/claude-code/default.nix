{
  pkgs,
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
    claude = lib.removeSuffix "\n" ''CC_SYSTEM_PROMPT=$(serena prompts print-cc-system-prompt-override) ${lib.getExe pkgs.claude-code} --system-prompt="$CC_SYSTEM_PROMPT"'';
  };

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    skills = {
      caveman = ../skills/caveman/SKILL.md;
    };
    # agents = agents;

    settings = {
      env = {
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = 1;
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
          (mkClaudePermissionList ["Write" "Edit"] sensitive_files.claude ++ lockfiles.claude)
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
