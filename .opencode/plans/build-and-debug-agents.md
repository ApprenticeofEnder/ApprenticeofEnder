# Plan: Build and Debug Agent Configuration

## Overview

Add prompts, permissions, and tooling for the **build** and **debug** agents in the OpenCode agent configuration at `modules/home/programs/opencode/agents/`.

## Files Touched

| File                                                | Change                                                                                                               |
| --------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `modules/home/programs/opencode/agents/default.nix` | Add `build` and `debug` attrsets with tools, permissions, prompt refs. Wire into `programs.opencode.settings.agent`. |
| `modules/home/programs/opencode/agents/build.md`    | Write full build agent prompt (currently empty).                                                                     |
| `modules/home/programs/opencode/agents/debug.md`    | Write full debug agent prompt (currently 5-line skeleton).                                                           |

## 1. `agents/default.nix` Changes

### Build Agent (Nix)

```nix
permissions.build = buildAccessList "allow" (
  mcpToolList "serena" [
    "create_*"
    "delete_*"
    "edit_*"
    "insert_*"
    "replace_*"
    "rename_*"
    "write_memory"
  ]
);

build = {
  mode = "primary";
  tools = {
    write = true;
    edit = true;
  };
  permission = permissions.build;
  prompt = builtins.readFile ./build.md;
};
```

- Mode: `primary` (switchable via Tab)
- Tools: All enabled (write, edit)
- Permissions: Explicitly allows Serena's write-capable tools. Global permissions in `permissions.nix` already set `serena_*` to `"ask"` and allow read-oriented tools; the build agent overrides those to also allow write operations.

### Debug Agent (Nix)

```nix
debugBashAllow = buildAccessList "allow" {
  "head *"
  "tail *"
  "wc *"
  "ls *"
  "grep *"
  "cat *"
  "find *"
  "rg *"
  "git log*"
  "git diff*"
  "git status*"
  "git show*"
};

permissions.debug =
  buildAccessList "deny" (
    mcpToolList "serena" [
      "delete_*"
      "insert_*"
      "replace_*"
      "rename_*"
    ]
  )
  // {
    bash = {
      "*" = "ask";
    } // debugBashAllow;
  };

debug = {
  mode = "primary";
  tools = {
    write = false;
    edit = false;
  };
  permission = permissions.debug;
  prompt = builtins.readFile ./debug.md;
};
```

- Mode: `primary` (switchable via Tab)
- Tools: Read-only (write and edit disabled)
- Permissions: Serena write tools denied. Bash: read-only commands (grep, ls, cat, find, rg, git log/diff/status/show, head, tail, wc) allowed freely; everything else prompts via `"ask"`.

### Wire Into Settings

```nix
programs.opencode = {
  settings = {
    agent = {
      plan = plan;
      build = build;
      debug = debug;
    };
  };
};
```

## 2. `agents/build.md` Prompt

Role: Expert implementer that executes plans and writes code.

Contents:

- **Role statement**: Expert software engineer focused on implementation
- **Plan awareness**: Check `.opencode/plans/` for existing approved plans before starting work
- **Principles** (tuned for implementation):
  1. Assume Nothing, Question Everything
  2. Simplicity First
  3. Surgical Changes
  4. Never Nesting (max 3 layers deep)
  5. Modularity and Reusability
  6. Security and Robustness
- **Process**:
  1. **Onboarding**: Check Serena MCP server is onboarded. If not, delegate to @onboarding or @general agent.
  2. **Plan Check**: Look in `.opencode/plans/` for an approved plan relevant to the task. If one exists, follow it. If not, proceed based on the user's request.
  3. **Recon**: If context is insufficient, use @explore to find relevant files/symbols.
  4. **Implement**: Write the code. Follow the principles. Make surgical, testable changes.
  5. **Verify**: Run available tests or build commands to validate. If tests fail, fix them before reporting completion.

## 3. `agents/debug.md` Prompt

Role: Expert troubleshooter -- investigates, diagnoses, reports.

Contents:

- **Role statement**: Expert troubleshooter and debugger
- **Explicit constraint**: Cannot modify files; provides findings and recommended fixes with specific file/line/change references
- **Principles** (tuned for investigation):
  1. Assume Nothing, Question Everything -- same as plan
  2. Trace the Evidence -- follow error messages, stack traces, and logs methodically
  3. Check Recent Changes -- use `git log`, `git diff` to find what changed recently
  4. Isolate the Problem -- narrow scope from broad symptoms to specific root cause
- **Process**:
  1. **Onboarding**: Check Serena MCP server is onboarded. If not, delegate.
  2. **Understand the Issue**: Clarify symptoms, reproduction steps, expected vs actual behavior.
  3. **Investigate**: Use available tools (Serena read/search, bash read-only commands, git history) to trace the problem.
  4. **Diagnose**: Identify the root cause. State it explicitly.
  5. **Report**: Provide a clear report with: root cause, affected files/lines, recommended fix (specific code changes), and any related risks or side effects.

## Notes

- The `permissions.nix` global permissions remain untouched. Agent-level permissions override/merge with globals per OpenCode's "last matching rule wins" semantics.
- Both agents use `builtins.readFile` for their prompts, same pattern as `plan`.
- The `buildAccessList` and `mcpToolList` helpers in `agents/default.nix` are reused for both new agents (no refactoring needed).
