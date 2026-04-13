{...}: let
  buildAccessList = accessValue: (
    list:
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

  mcpToolList = prefix: (tools: (map (tool: "${prefix}_${tool}") tools));

  # Serena

  serenaAllow = buildAccessList "allow" (
    mcpToolList "serena" [
      "check_onboarding_performed"
      "find_*"
      "get_*"
      "initial_instructions"
      "list_*"
      "read_*"
      "search_*"
      "think_*"
      "edit_memory"
      "write_memory"
    ]
  );

  serenaPerms =
    {
      "serena_*" = "ask";
    }
    // serenaAllow;

  # Bash

  bashAllow = buildAccessList "allow" [
    "head *"
    "wc *"
    "ls *"
  ];

  bashPerms =
    {
      "*" = "deny";
    }
    // bashAllow;

  fileReadPerms = {
    "*" = "allow";
    "*.vars" = "deny";
    "*.env" = "deny";
    "*.secrets" = "deny";
    "*.env.*" = "deny";
    "*.env.example" = "allow";
  };
  permissions =
    {
      read = fileReadPerms;
      edit = "ask";
      bash = bashPerms;

      webfetch = "ask";
      grep = fileReadPerms;
    }
    // serenaPerms;
in {
  programs.opencode = {
    settings = {
      permission = permissions;
    };
  };
}
