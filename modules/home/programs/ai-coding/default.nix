{...}: {
  imports =
    [
      # keep-sorted start
      ./claude-code
      ./cursor
      ./mcp.nix
      ./opencode
      # keep-sorted end
    ]
    ++ (map (agent: ./agents/${agent}) [
      "debugger"
    ]);
}
