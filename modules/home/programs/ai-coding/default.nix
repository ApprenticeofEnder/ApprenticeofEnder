{...}: {
  imports = [
    # keep-sorted start
    ./agents/critic
    ./agents/debugger
    ./agents/fleet.nix
    ./agents/plan
    ./claude-code
    ./cursor
    ./mcp.nix
    ./opencode
    # keep-sorted end
  ];
}
