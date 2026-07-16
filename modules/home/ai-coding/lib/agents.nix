{lib, ...}: let
  data = import ./data.nix {inherit lib;};
  permissions = import ./permissions.nix {inherit lib;};
  inherit (data) toYaml;
  inherit (permissions) mergeClaudePermissionGroups;
  inherit (permissions) claude_permission_groups;
  inherit (permissions) opencode_permission_groups;
in rec {
  mkClaudeCodeAgent = {
    frontmatter,
    prompt,
  }: ''
    ---
    ${toYaml frontmatter}
    ---
    ${prompt}
  '';

  mkOpenCodeAgent = {
    frontmatter,
    prompt,
  }:
    frontmatter
    // {
      prompt = prompt;
    };

  mkAgent = {
    name,
    description,
    permission_groups ? ["read" "edit" "bash"],
    claude_model ? "sonnet",
    opencode_model ? "kimi-k27",
    cursor_model ? "composer",
    agent_mode ? "all",
    prompt_file ? ../agents/${name}/agent.md,
    # cursor ? {},
  }: let
    baseConfig = {
      name = name;
      description = description;
    };

    permissions = {
      claude = mergeClaudePermissionGroups (
        map (group: claude_permission_groups."${group}") permission_groups
      );
      opencode = lib.mergeAttrsList (
        map (group: opencode_permission_groups."${group}") permission_groups
      );
      cursor = {
        readonly = let
          matching_groups = lib.intersectLists permission_groups ["edit" "bash"];
        in
          builtins.length matching_groups <= 0;
      };
    };

    models = selectModels {
      cursor = cursor_model;
      claude = claude_model;
      opencode = opencode_model;
    };

    opencode = {
      model = models.opencode;
      permission = permissions.opencode;
      mode = agent_mode;
    };

    claude =
      {
        model = models.claude;
      }
      // permissions.claude;

    cursor =
      {
        model = models.cursor;
      }
      // permissions.cursor;

    prompt = builtins.readFile prompt_file;
  in
    lib.mkMerge [
      {
        programs.opencode.settings.agent."${name}" = mkOpenCodeAgent {
          inherit prompt;
          frontmatter = baseConfig // opencode;
        };
      }
      {
        programs.claude-code.agents."${name}" = mkClaudeCodeAgent {
          inherit prompt;
          frontmatter = baseConfig // claude;
        };
      }
      {
        home.file.".cursor/agents/${name}.md" = {
          text = mkClaudeCodeAgent {
            inherit prompt;
            frontmatter = baseConfig // cursor;
          };
        };
      }
    ];

  models = {
    opencode = let
      openrouter_models = {
        # keep-sorted start
        deepseek-v4 = "deepseek/deepseek-v4-flash";
        kimi-k27 = "moonshotai/kimi-k2.7-code";
        minimax-m3 = "minimax/minimax-m3";
        nemotron = "nvidia/nemotron-3-ultra-550b-a55b";
        north-mini = "cohere/north-mini-code:free";
        owl-alpha = "openrouter/owl-alpha";
        z-ai = "z-ai/glm-5.2";
        # keep-sorted end
      };
    in
      {
        haiku = "github-copilot/claude-haiku-4.5";
        sonnet = "github-copilot/claude-sonnet-4.6";
        opus = "github-copilot/claude-opus-4.6";
      }
      // (
        lib.concatMapAttrs (id: model: {
          "${id}" = "openrouter/${model}";
        })
        openrouter_models
      );
    claude = {
      haiku = "haiku";
      sonnet = "sonnet";
      opus = "opus";
    };
    cursor = {
      composer = "composer-2.5";
      # TODO: Populate other models
    };
  };

  selectModels = {
    opencode ? "sonnet",
    claude ? "sonnet",
    cursor ? "composer",
  }: {
    opencode = models.opencode."${opencode}";
    claude = models.claude."${claude}";
    cursor = models.cursor."${cursor}";
  };
}
