{lib, ...}: rec {
  mcpToolList = {
    name,
    style,
  }: (
    tools: (
      map (tool:
        if style == "opencode"
        then "${name}_${tool}"
        else "mcp__${name}__${name}_${tool}")
      tools
    )
  );

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
      (lib.mkIf (read != null) {inherit read;})
      (lib.mkIf (edit != null) {inherit edit;})

      (lib.mkIf (glob != null) {inherit glob;})
      (lib.mkIf (glob == null && read != null) {glob = read;})

      (lib.mkIf (grep != null) {inherit grep;})
      (lib.mkIf (grep == null && read != null) {grep = read;})

      (lib.mkIf (bash != null) {inherit bash;})

      (lib.mkIf (webfetch != null) {inherit webfetch;})
      (lib.mkIf (websearch != null) {inherit websearch;})
      (lib.mkIf (skill != null) {inherit skill;})
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
