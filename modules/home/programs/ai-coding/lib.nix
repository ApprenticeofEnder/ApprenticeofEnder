{...}: let
  # toYAML = pkgs.formats.yaml.generate {};
  mkClaudeCodeAgent = {
    frontmatter,
    prompt,
  }: ''
    ---
    ${frontmatter}
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
in {
  mkAgents = agent_name: let
    agentFile = file: ./agents/${agent_name}/${file};
    claude_frontmatter = builtins.fromJSON (
      builtins.readFile (agentFile "claude-config.json")
    );
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

  buildAccessList = {
    allow ? [],
    ask ? [],
    deny ? [],
  }: let
    mkList = accessValue: list: (
      builtins.listToAttrs (
        map (
          permission: {
            name = permission;
            value = accessValue;
          }
        )
        list
      )
    );
  in (
    mkList "deny" deny
    // mkList "ask" ask
    // mkList "allow" allow
  );

  mcpToolList = {
    name,
    style,
  }: (
    tools: (
      map (tool:
        if style == "opencode"
        then "${name}_${tool}"
        else "mcp__${name}__${name}_${tool}")
      tools
    )
  );
}
