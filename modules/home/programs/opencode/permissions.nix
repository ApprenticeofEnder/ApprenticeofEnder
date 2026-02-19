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

  toolList = prefix: (tools: (map (tool: "${prefix}_${tool}") tools));

  serenaAllow = buildAccessList "allow" (
    toolList "serena" [
      "check_onboarding_performed"
      "find_*"
      "get_*"
      "initial_instructions"
      "list_*"
      "read_*"
      "search_*"
    ]
  );

  permissions =
    {
      read = {
        "*" = "allow";
        "*.env" = "deny";
      };
      edit = "ask";
      bash = {
        "*" = "ask";
      };

      webfetch = "ask";

      "serena_*" = "ask";
    }
    // serenaAllow;
in {
  programs.opencode = {
    settings = {
      permission = permissions;
    };
  };
}
