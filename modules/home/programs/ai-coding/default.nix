{...}: {
  imports = [
    # keep-sorted start
    ./agents/debugger
    ./agents/fleet.nix
    ./claude-code
    ./cursor
    ./mcp.nix
    ./opencode
    # keep-sorted end
  ];

  home.file = {
    ".agents/tasks/missive.md" = {
      source = ./tasks/missive.md;
    };
  };
}
