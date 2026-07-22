{lib, ...}: let
  ai_coding_lib = import ../../lib {
    inherit lib;
  };
  inherit (ai_coding_lib) mkAgent;

  agents = {
    critic = {
      description = ''
        Reviews overall project state and provides objective, direct feedback with constructive criticism and suggestions for improvement. Use at significant milestones, after major changes, or when reviewing a diff before it lands.
      '';
      claude_model = "opus";
      opencode_model = "kimi-k27";
    };
    deduplicator = {
      description = ''
        Improves a change by removing unnecessary duplication.
      '';
    };
    drafter = {
      description = ''
        Creates the first draft of a change.
      '';
    };
    renamer = {
      description = ''
        Improves naming conventions in a change.
      '';
    };
    simplifier = {
      description = ''
        Simplifies logic of a change.
      '';
    };
    tester = {
      description = ''
        Identifies failure points and edge cases in a change.
      '';
    };
  };
in
  lib.mkMerge (
    lib.mapAttrsToList (
      name: agent:
        mkAgent (
          lib.mergeAttrsList [
            {
              inherit name;
              description = agent.description;
              agent_mode = "subagent";
              prompt_file = ./${name}/agent.md;
            }
            (lib.optionalAttrs (lib.hasAttrByPath ["claude_model"] agent) {
              claude_model = agent.claude_model;
            })
            (lib.optionalAttrs (lib.hasAttrByPath ["opencode_model"] agent) {
              opencode_model = agent.opencode_model;
            })
          ]
        )
    )
    agents
  )
