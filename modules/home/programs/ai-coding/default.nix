{...}: {
  imports = [
    # keep-sorted start
    ./agents/critic
    ./agents/debugger
    ./agents/fleet.nix
    ./claude-code
    ./cursor
    ./mcp.nix
    ./opencode
    # keep-sorted end
  ];
}
