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
  ];

  bashPerms =
    {
      "*" = "ask";
    }
    // bashAllow;

  permissions =
    {
      read = {
        "*" = "allow";
        "*.env" = "deny";
      };
      edit = "ask";
      bash = bashPerms;

      webfetch = "ask";
    }
    // serenaPerms;
in {
  programs.opencode = {
    settings = {
      permission = permissions;
    };
  };
}
