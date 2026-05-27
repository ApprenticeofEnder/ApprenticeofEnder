# Plan: Shared AI Coding Permission Mapping Library

## Goal

Create a Nix function library that converts a shared intermediate permission format into both Claude Code and OpenCode permission configurations.

## File

`modules/home/programs/ai-coding/permissions-lib.nix`

Single file, takes `{ lib }`, exports `{ toClaudePermissions, toOpencodePermissions }`.

## Intermediate Permission Format

```nix
{
  # Common tools - mapped to both platforms
  # Value: "action" string OR { pattern = "action"; } attrset
  bash = { "*" = "deny"; "git *" = "allow"; "npm *" = "allow"; };
  edit = "ask";
  read = { "*" = "allow"; "*.env" = "deny"; };   # expands to read+grep+glob in OpenCode
  grep = { "*.secret" = "deny"; };                # optional: overrides read expansion
  glob = "allow";                                  # optional: overrides read expansion
  webfetch = "ask";
  websearch = "deny";
  subagent = "allow";    # Agent in Claude, task in OpenCode
  skill = { caveman = "allow"; "*" = "ask"; };
  lsp = "allow";

  # MCP tools
  mcp.serena = { "find_*" = "allow"; "get_*" = "allow"; "*" = "ask"; };

  # Platform-specific (silently dropped in other direction)
  opencodeOnly = {
    question = "allow";
    doom_loop = "ask";
    external_directory = { "~/projects/*" = "allow"; };
  };
  claudeOnly = {
    notebookEdit = "ask";
    monitor = "deny";
  };
}
```

## Tool Name Mappings

| Intermediate | Claude | OpenCode |
|---|---|---|
| `bash` | `Bash` | `bash` |
| `edit` | `Edit` + `Write` | `edit` |
| `read` | `Read` | `read` + `grep` + `glob` |
| `glob` | `Glob` | `glob` (overrides read expansion) |
| `grep` | `Grep` | `grep` (overrides read expansion) |
| `webfetch` | `WebFetch` | `webfetch` |
| `websearch` | `WebSearch` | `websearch` |
| `subagent` | `Agent` | `task` |
| `skill` | `Skill` | `skill` |
| `lsp` | `LSP` | `lsp` |
| `mcp.X.Y` | `mcp__X__Y` | `X_Y` |

### Claude-Only Tool Names

| Intermediate | Claude |
|---|---|
| `notebookEdit` | `NotebookEdit` |
| `monitor` | `Monitor` |
| `powershell` | `PowerShell` |

## `toClaudePermissions` Output

```nix
{
  allow = [ "Bash(git *)" "Bash(npm *)" "Read" "Glob" "Skill(caveman)" "mcp__serena__find_*" "mcp__serena__get_*" ];
  deny = [ "Bash" "WebSearch" ];
  ask = [ "Edit" "Write" "WebFetch" "Skill" "mcp__serena" ];
}
```

### Rules

- `pattern == "*"` -> bare tool name (`"Bash"`)
- Otherwise -> `"ToolName(pattern)"` (`"Bash(git *)"`)
- `claudeOnly` mapped via name table
- `opencodeOnly` silently dropped
- MCP `"*"` -> `mcp__server`; specific pattern -> `mcp__server__pattern`

## `toOpencodePermissions` Output

```nix
{
  bash = { "*" = "deny"; "git *" = "allow"; "npm *" = "allow"; };
  edit = "ask";
  read = { "*" = "allow"; "*.env" = "deny"; };
  grep = { "*" = "allow"; "*.env" = "deny"; "*.secret" = "deny"; };  # merged with read
  glob = "allow";                                                       # explicit override
  webfetch = "ask";
  websearch = "deny";
  task = "allow";
  skill = { caveman = "allow"; "*" = "ask"; };
  lsp = "allow";
  question = "allow";
  doom_loop = "ask";
  external_directory = { "~/projects/*" = "allow"; };
  "serena_find_*" = "allow";
  "serena_get_*" = "allow";
  "serena_*" = "ask";
}
```

### Rules

- `read` expands to `read` + `grep` + `glob`
- Explicit `grep`/`glob` merges on top (string replaces; attrset merges with explicit winning conflicts)
- Pattern conversion: `**` -> `*`
- `opencodeOnly` mapped directly as top-level keys
- `claudeOnly` silently dropped
- MCP: `serverName_toolPattern` as top-level keys

## Merge Logic (read -> grep/glob)

1. Process `read` first -> populates `read`, `grep`, `glob` in output
2. Process all other tools -> explicit `grep`/`glob` override:
   - String value -> replaces entirely
   - Attrset value -> merges (`existing // explicit`, explicit wins on conflict)

## Implementation

```nix
# modules/home/programs/ai-coding/permissions-lib.nix
#
# Shared permission format -> Claude Code / OpenCode permission configs.
#
# Usage:
#   let
#     permLib = import ./permissions-lib.nix { inherit lib; };
#     shared = { bash = { "*" = "deny"; "git *" = "allow"; }; ... };
#   in {
#     programs.claude-code.settings.permissions = permLib.toClaudePermissions shared;
#     programs.opencode.settings.permission = permLib.toOpencodePermissions shared;
#   }
{ lib }:
let
  inherit (lib)
    concatMap
    filterAttrs
    flatten
    foldl'
    mapAttrs
    mapAttrs'
    mapAttrsToList
    nameValuePair
    ;
  inherit (builtins) isAttrs isString replaceStrings filter;

  # ── Tool Name Tables ─────────────────────────────────────────

  claudeTools = {
    bash = ["Bash"];
    edit = ["Edit" "Write"];
    read = ["Read"];
    glob = ["Glob"];
    grep = ["Grep"];
    webfetch = ["WebFetch"];
    websearch = ["WebSearch"];
    subagent = ["Agent"];
    skill = ["Skill"];
    lsp = ["LSP"];
  };

  opencodeTools = {
    bash = ["bash"];
    edit = ["edit"];
    read = ["read" "grep" "glob"];
    glob = ["glob"];
    grep = ["grep"];
    webfetch = ["webfetch"];
    websearch = ["websearch"];
    subagent = ["task"];
    skill = ["skill"];
    lsp = ["lsp"];
  };

  claudeOnlyNames = {
    notebookEdit = "NotebookEdit";
    monitor = "Monitor";
    powershell = "PowerShell";
  };

  # ── Helpers ──────────────────────────────────────────────────

  mkClaudeRule = tool: pattern:
    if pattern == "*"
    then tool
    else "${tool}(${pattern})";

  toOcPattern = pat: replaceStrings ["**"] ["*"] pat;

  commonOf = table: perms:
    filterAttrs (k: _: table ? ${k})
      (removeAttrs perms ["mcp" "opencodeOnly" "claudeOnly"]);

  mergePerms = existing: new:
    if existing == null
    then new
    else if isString new
    then new
    else if isString existing
    then new
    else existing // new;

  # ── toClaudePermissions ──────────────────────────────────────

  toClaudePermissions = perms:
    let
      mkRules = claudeNames: perm:
        if isString perm
        then map (t: { rule = mkClaudeRule t "*"; action = perm; }) claudeNames
        else if isAttrs perm
        then concatMap
          (t: mapAttrsToList (pat: action: { rule = mkClaudeRule t pat; inherit action; }) perm)
          claudeNames
        else [];

      commonRules = flatten (mapAttrsToList
        (name: perm: mkRules claudeTools.${name} perm)
        (commonOf claudeTools perms));

      claudeOnlyRules =
        if perms ? claudeOnly
        then flatten (mapAttrsToList (name: perm:
          mkRules [(claudeOnlyNames.${name} or name)] perm
        ) perms.claudeOnly)
        else [];

      mcpRules =
        if perms ? mcp
        then flatten (mapAttrsToList (server: serverPerms:
          if isString serverPerms
          then [{ rule = "mcp__${server}"; action = serverPerms; }]
          else mapAttrsToList (pat: action: {
            rule =
              if pat == "*"
              then "mcp__${server}"
              else "mcp__${server}__${pat}";
            inherit action;
          }) serverPerms
        ) perms.mcp)
        else [];

      allRules = commonRules ++ claudeOnlyRules ++ mcpRules;

      byAction = action:
        map (r: r.rule) (filter (r: r.action == action) allRules);
    in {
      allow = byAction "allow";
      deny = byAction "deny";
      ask = byAction "ask";
    };

  # ── toOpencodePermissions ────────────────────────────────────

  toOpencodePermissions = perms:
    let
      common = commonOf opencodeTools perms;

      convertPerm = perm:
        if isString perm
        then perm
        else mapAttrs' (pat: action: nameValuePair (toOcPattern pat) action) perm;

      # Step 1: expand read to read+grep+glob
      readBase =
        if common ? read
        then
          let p = convertPerm common.read;
          in { read = p; grep = p; glob = p; }
        else {};

      # Step 2: layer remaining common tools (explicit grep/glob override)
      rest = filterAttrs (k: _: k != "read") common;
      expanded = foldl'
        (acc: { name, value }:
          let
            ocNames = opencodeTools.${name};
            converted = convertPerm value;
          in
            foldl'
            (acc2: ocName: acc2 // { ${ocName} = mergePerms (acc2.${ocName} or null) converted; })
            acc
            ocNames)
        readBase
        (mapAttrsToList (name: value: { inherit name value; }) rest);

      # OpenCode-only tools
      ocOnly =
        if perms ? opencodeOnly
        then mapAttrs (_: convertPerm) perms.opencodeOnly
        else {};

      # MCP -> flat top-level keys
      mcpFlat =
        if perms ? mcp
        then
          foldl'
          (acc: { server, serverPerms }:
            if isString serverPerms
            then acc // { "${server}_*" = serverPerms; }
            else
              acc
              // (mapAttrs'
                (pat: action: nameValuePair "${server}_${toOcPattern pat}" action)
                serverPerms))
          {}
          (mapAttrsToList
            (server: serverPerms: { inherit server serverPerms; })
            perms.mcp)
        else {};
    in
      expanded // ocOnly // mcpFlat;
in {
  inherit toClaudePermissions toOpencodePermissions;
}
```

## Known Limitations

1. **Eval order mismatch**: Claude uses deny-first (deny always wins regardless of specificity). OpenCode uses last-match-wins. The intermediate format follows last-match-wins semantics. If you write a broad deny + specific allow for the same tool, behavior will differ between platforms. Claude denies both; OpenCode allows the specific one. Use `claudeOnly`/`opencodeOnly` for platform-specific overrides if needed.

2. **Nix attrset key ordering**: Nix attrsets are sorted alphabetically by key. This generally produces correct OpenCode behavior (`"*"` sorts before letter patterns, specific patterns sort after broad ones), but edge cases are possible with unusual pattern combinations.

3. **Edit/Write split**: `edit` in intermediate format maps to both `Edit` and `Write` in Claude. For fine-grained control between Edit vs Write, use `claudeOnly`.

4. **WebFetch domain syntax**: Claude uses `WebFetch(domain:example.com)`. OpenCode matches URL patterns. The `domain:` prefix passes through unchanged and may not work as expected in OpenCode. Handle WebFetch patterns per-platform via `claudeOnly`/`opencodeOnly` if using domain matching.

5. **Claude Edit grants Read**: In Claude, an `Edit(...)` allow rule also grants read access to the same path. This implicit behavior is NOT replicated. If you need read access, set `read` explicitly.

## Usage Example

```nix
# In a module that configures both tools:
{ lib, ... }:
let
  permLib = import ../ai-coding/permissions-lib.nix { inherit lib; };

  sharedPerms = {
    bash = {
      "*" = "deny";
      "git *" = "allow";
      "npm *" = "allow";
    };
    read = {
      "*" = "allow";
      "*.env" = "deny";
      "*.env.*" = "deny";
      "*.env.example" = "allow";
    };
    edit = "ask";
    webfetch = "ask";
    lsp = "allow";
    skill = { caveman = "allow"; };

    mcp.serena = {
      "find_*" = "allow";
      "get_*" = "allow";
      "*" = "ask";
    };

    opencodeOnly = {
      question = "allow";
      doom_loop = "ask";
    };
  };
in {
  programs.claude-code.settings.permissions = permLib.toClaudePermissions sharedPerms;
  programs.opencode.settings.permission = permLib.toOpencodePermissions sharedPerms;
}
```

## Existing Code

`modules/home/programs/opencode/permissions.nix` is **NOT** refactored. This library is for future use / new configurations.
