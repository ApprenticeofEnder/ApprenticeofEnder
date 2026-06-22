{
  pkgs,
  lib,
  ...
}: let
  ai_coding_lib = import ../lib {inherit lib pkgs;};
  inherit (ai_coding_lib) collectLeafFiles;
  inherit (ai_coding_lib) cursor_serena_tools;
  inherit (ai_coding_lib) cursor_tools;
  inherit (ai_coding_lib) sensitive_files;
  inherit (ai_coding_lib) mkClaudePermissionList;
  inherit (ai_coding_lib) lockfiles;

  skill_file_paths = collectLeafFiles ../skills "";

  skill_files = with builtins;
    listToAttrs (
      map (fn: {
        name = ".cursor/skills/${fn}";
        value = {
          text = readFile (../skills + "/${fn}");
        };
      })
      skill_file_paths
    );

  config_files = {
    ".cursor/cli-config.json" = {
      text = builtins.toJSON {
        version = 1;
        editor.vimMode = true;
        permissions = {
          allow = lib.concatLists [
            (
              mkClaudePermissionList cursor_tools.read [
                "*"
                "*.env.example"
              ]
            )
            cursor_serena_tools.basic
          ];
          deny = lib.concatLists [
            (mkClaudePermissionList cursor_tools.read sensitive_files.claude)
            (mkClaudePermissionList cursor_tools.edit (sensitive_files.claude ++ lockfiles.claude))
          ];
        };
        rewind = true;
        display = {
          showLineNumbers = true;
          showThinkingBlocks = true;
        };
      };
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

    ".cursor/mcp.json" = {
      text = builtins.toJSON {
        mcpServers = {
          hashicorp-terraform = {
            command = "docker";
            args = [
              "run"
              "--rm"
              "--interactive"
              "--name"
              "terraform-mcp"
              "hashicorp/terraform-mcp-server:latest"
            ];
            type = "stdio";
          };
          serena = {
            command = "serena";
            args = [
              "start-mcp-server"
              "--context"
              "claude-code"
              "--project-from-cwd"
            ];
            type = "stdio";
          };
        };
      };
    };
  };
in {
  home.packages = with pkgs; [
    cursor-cli
  ];

  home.file = skill_files // config_files;
}
