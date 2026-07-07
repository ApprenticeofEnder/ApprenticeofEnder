{lib, ...}: let
  ai_coding_lib = import ../../lib {
    inherit lib;
  };

  inherit (ai_coding_lib) mkAgent;

  description = ''
    Drafts plans prior to implementation of a project, feature, bugfix, or other task. Use before any significant change involving multiple potential decisions.
  '';

  name = "plan";
in
  mkAgent {
    inherit name;
    inherit description;
    claude_model = "opus";
    opencode_model = "kimi-k27";
    permission_groups = ["read" "bash" "plan"];
  }
