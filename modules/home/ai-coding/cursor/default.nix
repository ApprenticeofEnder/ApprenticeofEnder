{
  pkgs,
  lib,
  ...
}: let
  ai_coding_lib = import ../lib {inherit lib pkgs;};
  inherit (ai_coding_lib) collectLeafFiles;
  inherit (ai_coding_lib) mcpToolSet;
  inherit (ai_coding_lib) serena_tools;
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

  mcp_tools = {
    serena = mcpToolSet {
      name = "serena";
      tools = {
        basic = serena_tools.basic;
        edit = serena_tools.edit;
      };
      agent = "cursor";
    };
  };

  # Cursor rewrites ~/.cursor/cli-config.json at runtime, so home-manager must not
  # manage it directly. Seed defaults once on first install instead.
  cliConfigSeed = pkgs.writeText "cursor-cli-config.json" (builtins.toJSON {
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
        mcp_tools.serena.basic
      ];
      deny = lib.concatLists [
        (mkClaudePermissionList cursor_tools.read sensitive_files.claude)
        (mkClaudePermissionList cursor_tools.edit (sensitive_files.claude ++ lockfiles.claude))
      ];
    };
    rewind = true;
    display = {
      showThinkingBlocks = true;
    };
  });

  config_files = {
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

  home.activation.seedCursorCliConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    target="$HOME/.cursor/cli-config.json"
    if [ ! -e "$target" ]; then
      $DRY_RUN_CMD mkdir -p "$(dirname "$target")"
      $DRY_RUN_CMD install -m 0644 ${cliConfigSeed} "$target"
      echo "Seeded $target (Cursor owns this file after first run)"
    fi
  '';
}
