{lib, ...}: rec {
  mcpToolList = {
    claude = {
      name,
      tools,
    }:
      map (tool: "mcp__${name}__${tool}") tools;

    opencode = {
      name,
      tools,
    }:
      map (tool: "${name}_${tool}") tools;

    cursor = _:
      throw "mcpToolList.cursor: not yet implemented";
  };

  mkClaudePermissionList = tools: specifiers:
    builtins.concatLists (
      map (
        tool:
          map (
            specifier: "${tool}(${specifier})"
          )
          specifiers
      )
      tools
    );

  formatClaudePermissionList = perms: builtins.concatStringsSep ", " perms;

  mkClaudePermissionGroup = {
    tools ? [],
    disallowedTools ? [],
  }: {
    tools = formatClaudePermissionList tools;
    disallowedTools = formatClaudePermissionList disallowedTools;
  };

  mkOpencodePermissionList = {
    allow ? [],
    ask ? [],
    deny ? [],
  }: let
    mkList = accessValue: list: (
      builtins.listToAttrs (
        map (
          permission: {
            name = permission;
            value = accessValue;
          }
        )
        list
      )
    );
  in
    lib.mergeAttrsList [
      (mkList "deny" deny)
      (mkList "ask" ask)
      (mkList "allow" allow)
    ];

  mkOpencodePermissionGroup = {
    read ? null,
    edit ? null,
    glob ? null,
    grep ? null,
    bash ? null,
    webfetch ? null,
    websearch ? null,
    skill ? null,
  }:
    lib.mergeAttrsList [
      (lib.optionalAttrs (read != null) {inherit read;})
      (lib.optionalAttrs (edit != null) {inherit edit;})

      (lib.optionalAttrs (glob != null) {inherit glob;})
      (lib.optionalAttrs (glob == null && read != null) {glob = read;})

      (lib.optionalAttrs (grep != null) {inherit grep;})
      (lib.optionalAttrs (grep == null && read != null) {grep = read;})

      (lib.optionalAttrs (bash != null) {inherit bash;})

      (lib.optionalAttrs (webfetch != null) {inherit webfetch;})
      (lib.optionalAttrs (websearch != null) {inherit websearch;})
      (lib.optionalAttrs (skill != null) {inherit skill;})
    ];

  sensitive_files = {
    claude = [
      "**/*.env"
      "**/*.env.*"
      "**/*.secrets.*"
      "**/*.vars.*"
      "~/.aws"
      "~/.ssh"
    ];
    opencode = [
      "*.env"
      "*.env.*"
      "*.vars"
      "*.secrets"
      "~/.aws"
      "~/.ssh"
    ];
  };

  lockfiles = {
    claude = [
      "**/*.lock"
    ];
    opencode = [
      "*.lock"
    ];
  };

  global_bash = {
    deny = [
      "curl *"
      "wget *"
      "nc *"
      "git push *"
    ];
    ask = ["*"];
    allow = [
      "git status"
      "git diff"
    ];
  };

  serena_tools = {
    basic = [
      "delete_memory"
      "edit_memory"
      "find_declaration"
      "find_implementations"
      "find_referencing_symbols"
      "find_symbol"
      "get_diagnostics_for_file"
      "initial_instructions"
      "list_memories"
      "onboarding"
      "read_memory"
      "rename_memory"
      "write_memory"
    ];
  };

  claude_permission_groups = {
    read = mkClaudePermissionGroup {
      tools = mkClaudePermissionList ["Read" "Grep" "Glob"] ["*"];
    };
    edit = mkClaudePermissionGroup {
      tools = mkClaudePermissionList ["Write" "Edit"] ["*"];
    };
    bash = mkClaudePermissionGroup {
      tools = mkClaudePermissionList ["Bash"] ["*"];
    };
  };

  mergeClaudePermissionGroups = groups: {
    tools = builtins.concatStringsSep ", " (
      builtins.filter (s: s != "") (map (g:
        if g.tools == null
        then ""
        else g.tools)
      groups)
    );
    disallowedTools = builtins.concatStringsSep ", " (
      builtins.filter (s: s != "") (map (g:
        if g.disallowedTools == null
        then ""
        else g.disallowedTools)
      groups)
    );
  };

  opencode_permission_groups = {
    read = mkOpencodePermissionGroup {
      read = mkOpencodePermissionList {
        deny = sensitive_files.opencode;
        allow = [
          "*"
          "*.env.example"
        ];
      };
    };
    edit = mkOpencodePermissionGroup {
      edit = mkOpencodePermissionList {
        deny = sensitive_files.opencode ++ lockfiles.opencode;
        allow = ["*"];
      };
    };
    bash = mkOpencodePermissionGroup {
      bash = mkOpencodePermissionList {
        deny = global_bash.deny;
        allow = global_bash.allow;
        ask = global_bash.ask;
      };
    };
    noedit = mkOpencodePermissionGroup {
      edit = "deny";
    };
    nobash = mkOpencodePermissionGroup {
      bash = "deny";
    };
  };
}
