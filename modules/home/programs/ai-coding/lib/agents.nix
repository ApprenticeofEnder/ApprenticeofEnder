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

  mkAgents = agent_name: let
    agentFile = file: ../agents/${agent_name}/${file};
    claude_frontmatter =
      builtins.readFile (agentFile "claude-config.yml");
    opencode_frontmatter = builtins.fromJSON (
      builtins.readFile (agentFile "opencode-config.json")
    );
    prompt = builtins.readFile (agentFile "agent.md");
  in {
    opencode = mkOpenCodeAgent {
      inherit prompt;
      frontmatter = opencode_frontmatter;
    };
    claude = mkClaudeCodeAgent {
      inherit prompt;
      frontmatter = claude_frontmatter;
    };
  };

  mkAgent = {
    name,
    description,
    permission_groups ? ["read" "edit" "bash"],
    claude_model ? "sonnet",
    opencode_model ? "sonnet",
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
      cursor = {}; # idk how cursor permissions work just yet
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
    ];

  models = {
    opencode = {
      haiku = "github-copilot/claude-haiku-4.5";
      sonnet = "github-copilot/claude-sonnet-4.6";
      opus = "github-copilot/claude-opus-4.6";
    };
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
