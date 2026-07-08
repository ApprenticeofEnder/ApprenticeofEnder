{...}: {
  imports = [
    # keep-sorted start
    ./agents/critic
    ./agents/debugger
    ./agents/fleet
    ./agents/plan
    ./claude-code
    ./cursor
    ./mcp.nix
    ./opencode
    # keep-sorted end
  ];
}
