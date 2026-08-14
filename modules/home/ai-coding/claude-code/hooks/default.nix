{lib, ...}: let
  mkScriptHook = name: let
    filePath = ".claude/hooks/${name}.sh";
  in {
    file = {
      "${filePath}" = {
        source = ./${name}.sh;
        executable = true;
      };
    };
    reference = "~/${filePath}";
  };

  hooks = {
    clamp-bash-timeout = mkScriptHook "clamp-bash-timeout";
    format = mkScriptHook "format";
  };

  hookFiles = lib.mergeAttrsList (builtins.attrValues (lib.concatMapAttrs (name: hook: {
      "${name}" = hook.file;
    })
    hooks));
in {
  home.file = hookFiles;
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
                command = "${hooks.clamp-bash-timeout.reference}";
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
        PostToolUse = [
          {
            matcher = "Edit|Write";
            hooks = [
              {
                type = "command";
                command = "${hooks.format.reference}";
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
