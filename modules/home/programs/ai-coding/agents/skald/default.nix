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
    Fleet worker, SONNET tier. Documentation generator — READMEs, API/reference docs, doc-comments, architecture notes, changelogs, usage guides, and onboarding docs derived from existing code. Dispatched by the lead thread with a single bounded task brief. Interchangeable with lanza (use distinct ones to run docs work in parallel). Drop to fencer/tabloid (haiku) for mechanical text edits; escalate to count/wiseman (sonnet) for code changes.
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

  name = "skald";

  opencodeConfig = {
    model = models.opencode;
    permission = permissions.opencode;
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
