{...}: {
  home.file = {
    ".claude/hooks/clamp-bash-timeout.sh" = {
      source = ./clamp-bash-timeout.sh;
      executable = true;
    };

    ".claude/hooks/force-skill.sh" = {
      source = ./force-skill.sh;
      executable = true;
    };
  };
  programs.claude-code = {
    settings = {
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
          {
            matcher = "mcp__serena__*";
            hooks = [
              {
                type = "command";
                command = "serena-hooks auto-approve --client=claude-code";
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
