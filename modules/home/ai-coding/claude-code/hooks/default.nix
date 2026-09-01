{lib, ...}: let
  mkScriptHook = {
    name,
    extension ? "sh",
  }: let
    filePath = ".claude/hooks/${name}.${extension}";
  in {
    file = {
      "${filePath}" = {
        source = ./${name}.${extension};
        executable = true;
      };
    };
    reference = "~/${filePath}";
  };

  hookScripts = {
    clamp-bash-timeout = mkScriptHook {name = "clamp-bash-timeout";};
    # format = mkScriptHook {
    #   name = "format";
    # };
    post-write = mkScriptHook {
      name = "post_format";
      extension = "py";
    };
  };

  hookFiles = lib.mergeAttrsList (builtins.attrValues (lib.concatMapAttrs (name: hook: {
      "${name}" = hook.file;
    })
    hookScripts));
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
                command = "${hookScripts.clamp-bash-timeout.reference}";
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
                command = "${hookScripts.post-write.reference}";
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
