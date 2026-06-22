{lib, ...}: rec {
  mcpToolList = {
    claude = {
      name,
      tools,
      home_manager ? false,
    }: let
      server_name =
        if home_manager
        then "plugin_claude-code-home-manager_${name}"
        else name;
    in
      map (
        tool: "mcp__${server_name}__${tool}"
      )
      tools;

    opencode = {
      name,
      tools,
    }:
      map (tool: "${name}_${tool}") tools;

    cursor = {
      name,
      tools,
    }:
      map (tool: "Mcp(${name}:${tool})") tools;
  };

  mkClaudePermissionList = tools: specifiers:
    builtins.concatLists (
      map (
        tool:
          if (lib.hasPrefix "mcp" tool || lib.hasPrefix "Mcp" tool)
          then lib.singleton tool
          else
            (
              map (
                specifier: "${tool}(${specifier})"
              )
              specifiers
            )
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
      "**/*.secrets"
      "**/*.secrets.*"
      "**/*.vars"
      "**/*.vars.*"
      "~/.aws"
      "~/.ssh"
    ];
    opencode = [
      "*.env"
      "*.env.*"
      "*.vars"
      "*.vars.*"
      "*.secrets"
      "*.secrets.*"
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
    edit = [
      "insert_after_symbol"
      "insert_before_symbol"
      "rename_symbol"
      "replace_content"
      "replace_symbol_body"
      "safe_delete_symbol"
    ];
  };

  claude_serena_tools = {
    basic = mcpToolList.claude {
      name = "serena";
      tools = serena_tools.basic;
      home_manager = true;
    };

    edit = mcpToolList.claude {
      name = "serena";
      tools = serena_tools.edit;
      home_manager = true;
    };
  };

  opencode_serena_tools = {
    basic = mcpToolList.opencode {
      name = "serena";
      tools = serena_tools.basic;
    };
    edit = mcpToolList.opencode {
      name = "serena";
      tools = serena_tools.edit;
    };
  };

  cursor_serena_tools = {
    basic = mcpToolList.cursor {
      name = "serena";
      tools = serena_tools.basic;
    };
    edit = mcpToolList.cursor {
      name = "serena";
      tools = serena_tools.edit;
    };
  };

  claude_tools = {
    read = ["Read" "Grep" "Glob"];
    edit = ["Write" "Edit"];
    bash = ["Bash"];
  };

  cursor_tools = {
    read = ["Read"];
    edit = ["Write"];
    bash = ["Shell"];
  };

  claude_permission_groups = let
    read = claude_tools.read ++ claude_serena_tools.basic;
    edit = claude_tools.edit ++ claude_serena_tools.edit;
  in {
    read = mkClaudePermissionGroup {
      tools = mkClaudePermissionList read ["*"];
    };
    edit = mkClaudePermissionGroup {
      tools = mkClaudePermissionList edit ["*"];
    };
    bash = mkClaudePermissionGroup {
      tools = mkClaudePermissionList claude_tools.bash ["*"];
    };
    noedit = mkClaudePermissionGroup {
      disallowedTools = mkClaudePermissionList edit ["*"];
    };
    nobash = mkClaudePermissionGroup {
      disallowedTools = mkClaudePermissionList claude_tools.bash ["*"];
    };
    plan = mkClaudePermissionGroup {
      tools = mkClaudePermissionList edit [".claude/plans/*.md"];
      disallowedTools = mkClaudePermissionList claude_tools.edit ["*"];
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
    plan = mkOpencodePermissionGroup {
      edit = {
        "*" = "deny";
        ".opencode/plans/*.md" = "allow";
      };
    };
  };
}
