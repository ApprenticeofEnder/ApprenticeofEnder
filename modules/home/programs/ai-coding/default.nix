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
}
