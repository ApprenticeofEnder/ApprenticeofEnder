{lib, ...}: let
  ai_coding_lib = import ../../lib {
    inherit lib;
  };

  inherit (ai_coding_lib) mkAgent;

  description = ''
    Implements plans drafted with the plan agent.
  '';

  name = "build";
in
  mkAgent {
    inherit name;
    inherit description;
    claude_model = "opus";
    opencode_model = "kimi-k27";
    permission_groups = ["read" "bash" "plan"];
  }
