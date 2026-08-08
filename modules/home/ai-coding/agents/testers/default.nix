{lib, ...}: let
  ai_coding_lib = import ../../lib {
    inherit lib;
  };
  inherit (ai_coding_lib) mkAgent;

  agents = {
    adjacent-analysis = {
      description = ''
        Analyzes functions and finds their direct callers/callees for boundary mismatches and contract gaps.
      '';
    };
    control-flow-extraction = {
      description = ''
        Analyzes functions and finds conditions, order of operations, state transitions, and early returns/error paths.
      '';
    };
    property-extraction = {
      description = ''
        Analyzes functions and finds invariants and inputs that exercise them, along with expected outputs.
      '';
    };
  };
in
  lib.mkMerge (
    lib.mapAttrsToList (
      name: agent:
        mkAgent {
          inherit name;
          description = agent.description;
          agent_mode = "subagent";
          prompt_file = ./${name}/agent.md;
        }
    )
    agents
  )
