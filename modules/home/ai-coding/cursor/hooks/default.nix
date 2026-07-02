{...}: {
  home.file = {
    ".cursor/hooks/force-skill.sh" = {
      source = ./force-skill.sh;
      executable = true;
    };

    ".cursor/hooks.json" = {
      text = builtins.toJSON {
        version = 1;

        hooks = {
          preToolUse = [
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
          sessionStart = [
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
          beforeSubmitPrompt = [
            {
              hooks = [
                {
                  type = "command";
                  command = "~/.claude/hooks/force-skill.sh";
                }
              ];
            }
          ];
          sessionEnd = [
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
  };
}
