{lib, ...}: let
  ai_coding_lib = import ../../lib {
    inherit lib;
  };

  inherit (ai_coding_lib) mkAgent;

  description = ''
    Use this agent when you need to diagnose and fix bugs,
    identify root causes of failures, or analyze error logs
    and stack traces to resolve issues.
  '';

  name = "debugger";
  # TODO: Convert parts of the debugger subagent into skills
in
  mkAgent {
    inherit name;
    inherit description;
  }
