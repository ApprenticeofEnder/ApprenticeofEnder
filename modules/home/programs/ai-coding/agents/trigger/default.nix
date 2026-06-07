{lib, ...}: let
  ai_coding_lib = import ../../lib {
    inherit lib;
  };

  inherit (ai_coding_lib) selectModels;
  inherit (ai_coding_lib) mkAgent;
  inherit (ai_coding_lib) claude_permission_groups;
  inherit (ai_coding_lib) opencode_permission_groups;
  inherit (ai_coding_lib) mergeClaudePermissionGroups;

  description = ''
    Fleet worker, OPUS tier. Use for the hardest, architectural, or security-critical scoped build tasks — auth, authorizers, crypto, data-model design, anything where a subtle mistake is expensive. Dispatched by the lead thread with a single bounded task brief. Not for trivial mechanical edits (use fencer) or moderate work (use count/wiseman).
  '';

  permissions = {
    claude = mergeClaudePermissionGroups [
      claude_permission_groups.read
      claude_permission_groups.edit
      claude_permission_groups.bash
    ];
    cursor = {};
    opencode = lib.mergeAttrsList [
      opencode_permission_groups.read
      opencode_permission_groups.edit
      opencode_permission_groups.bash
    ];
  };

  models = selectModels {
    claude = "opus";
    opencode = "opus";
  };

  name = "trigger";

  opencodeConfig = {
    model = models.opencode;
    permission = permissions.opencode;
    mode = "subagent";
  };

  claudeConfig =
    {
      model = models.claude;
    }
    // permissions.claude;
in
  mkAgent {
    inherit name;
    inherit description;
    opencode = opencodeConfig;
    claude = claudeConfig;
  }
