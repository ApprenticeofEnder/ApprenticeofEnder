{lib, ...}: let
  data = import ./data.nix {inherit lib;};
  inherit (data) toYaml;
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
    opencode ? {},
    claude ? {},
    # cursor ? {},
  }: let
    baseConfig = {
      name = name;
      description = description;
    };

    prompt = builtins.readFile ../agents/${name}/agent.md;
  in
    lib.mkMerge [
      (lib.mkIf (opencode != null) {
        programs.opencode.settings.agent."${name}" = mkOpenCodeAgent {
          inherit prompt;
          frontmatter = baseConfig // opencode;
        };
      })
      (lib.mkIf (claude != null) {
        programs.claude-code.agents."${name}" = mkClaudeCodeAgent {
          inherit prompt;
          frontmatter = baseConfig // claude;
        };
      })
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
