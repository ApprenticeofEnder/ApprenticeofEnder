{lib, ...}: let
  ai_coding_lib = import ../lib {
    inherit lib;
  };
  inherit (ai_coding_lib) mkAgent;

  # TODO: Condense fleet agents into better defined terms
  # - Architect (Opus)
  # - Builder (Haiku)
  # - Test Generator (Sonnet)
  # - Documentation Generator (Sonnet)
  # - Precision File Editor (Haiku)
  # - Toolchain Engineer (Sonnet)
  # - Backend Engineer (Sonnet)
  # - Frontend Engineer (Sonnet)

  fleet_agents = {
    count = {
      description = ''
        Fleet worker, SONNET tier. Use for moderate scoped build tasks — domain types, schemas, module logic, standard feature slices. Dispatched by the lead thread with a single bounded task brief. Escalate to trigger (opus) for security-critical/architectural work; drop to fencer (haiku) for mechanical edits. Interchangeable with wiseman/jaeger.
      '';
    };
    fencer = {
      description = ''
        Fleet worker, HAIKU tier. Use for mechanical, well-specified scoped tasks — boilerplate, config files, renames, format-preserving edits, env/compose setup, anything where the steps are obvious and judgment is minimal. Dispatched by the lead thread with a single bounded task brief. Escalate to count/wiseman (sonnet) when the task needs design judgment, or trigger (opus) when it is security-critical. Interchangeable with tabloid.
      '';
      claude_model = "haiku";
      opencode_model = "haiku";
    };
    huxian = {
      description = ''
        Fleet worker, SONNET tier. Test generator — unit, integration, and edge-case tests for existing code: fixtures, mocks, table-driven cases, coverage gaps, regression tests for known bugs. Dispatched by the lead thread with a single bounded task brief. Interchangeable with tailor (use distinct ones to run test work in parallel). Escalate to trigger (opus) for security-critical test design; drop to fencer/tabloid (haiku) for mechanical test-file edits.
      '';
    };
    jaeger = {
      description = ''
        Fleet worker, SONNET tier. Use for moderate scoped build tasks — frontend/UI slices, module logic, standard feature work. Dispatched by the lead thread with a single bounded task brief. Escalate to trigger (opus) for security-critical/architectural work; drop to fencer (haiku) for mechanical edits. Interchangeable with count/wiseman.
      '';
    };
    lanza = {
      description = ''
        Fleet worker, SONNET tier. Documentation generator — READMEs, API/reference docs, doc-comments, architecture notes, changelogs, usage guides, and onboarding docs derived from existing code. Dispatched by the lead thread with a single bounded task brief. Interchangeable with skald (use distinct ones to run docs work in parallel). Drop to fencer/tabloid (haiku) for mechanical text edits; escalate to count/wiseman (sonnet) for code changes.
      '';
    };
    skald = {
      description = ''
        Fleet worker, SONNET tier. Documentation generator — READMEs, API/reference docs, doc-comments, architecture notes, changelogs, usage guides, and onboarding docs derived from existing code. Dispatched by the lead thread with a single bounded task brief. Interchangeable with lanza (use distinct ones to run docs work in parallel). Drop to fencer/tabloid (haiku) for mechanical text edits; escalate to count/wiseman (sonnet) for code changes.
      '';
    };
    tabloid = {
      description = ''
        Fleet worker, HAIKU tier. Precision file editor — surgical, format-preserving edits across one or a few files: targeted line/function changes, mechanical renames, signature tweaks, import fixups, comment/format cleanups where the exact change is already specified. Dispatched by the lead thread with a single bounded task brief. Interchangeable with fencer. Escalate to count/wiseman (sonnet) when the edit needs design judgment, or trigger (opus) when it is security-critical.
      '';
      claude_model = "haiku";
      opencode_model = "haiku";
    };
    tailor = {
      description = ''
        Fleet worker, SONNET tier. Test generator — unit, integration, and edge-case tests for existing code: fixtures, mocks, table-driven cases, coverage gaps, regression tests for known bugs. Dispatched by the lead thread with a single bounded task brief. Interchangeable with huxian (use distinct ones to run test work in parallel). Escalate to trigger (opus) for security-critical test design; drop to fencer/tabloid (haiku) for mechanical test-file edits.
      '';
    };
    trigger = {
      description = ''
        Fleet worker, OPUS tier. Use for the hardest, architectural, or security-critical scoped build tasks — auth, authorizers, crypto, data-model design, anything where a subtle mistake is expensive. Dispatched by the lead thread with a single bounded task brief. Not for trivial mechanical edits (use fencer) or moderate work (use count/wiseman).
      '';
      claude_model = "opus";
      opencode_model = "opus";
    };
    wiseman = {
      description = ''
        Fleet worker, SONNET tier. Use for moderate scoped build tasks — scaffolding, toolchain/config setup, module logic, standard feature slices. Dispatched by the lead thread with a single bounded task brief. Escalate to trigger (opus) for security-critical/architectural work; drop to fencer (haiku) for mechanical edits. Interchangeable with count/jaeger.
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
    fleet_agents
  )
