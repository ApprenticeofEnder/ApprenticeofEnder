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
    Fleet worker, SONNET tier. Use for moderate scoped build tasks — scaffolding, toolchain/config setup, module logic, standard feature slices. Dispatched by the lead thread with a single bounded task brief. Escalate to trigger (opus) for security-critical/architectural work; drop to fencer (haiku) for mechanical edits. Interchangeable with count/jaeger.
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

  models = selectModels {};

  name = "wiseman";

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
