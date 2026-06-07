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
    Fleet worker, HAIKU tier. Use for mechanical, well-specified scoped tasks — boilerplate, config files, renames, format-preserving edits, env/compose setup, anything where the steps are obvious and judgment is minimal. Dispatched by the lead thread with a single bounded task brief. Escalate to count/wiseman (sonnet) when the task needs design judgment, or trigger (opus) when it is security-critical. Interchangeable with tabloid.
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
    claude = "haiku";
    opencode = "haiku";
  };

  name = "fencer";

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
