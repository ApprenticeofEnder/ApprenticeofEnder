{...}: let
  /*
  Builds an access control list for OpenCode permissions.

  Inputs:
    accessValue: The level of access to give to the given values list. Value options: "ask" | "allow" | "deny"
    resources: The list of resources to assign access values.
  Output:
    Attribute set of the form: {
      resource = accessValue
    }
  */
  buildAccessList = accessValue: (
    resources:
      builtins.listToAttrs (
        map
        (
          permission: {
            name = permission;
            value = accessValue;
          }
        )
        resources
      )
  );

  /*
  Builds a list of MCP tools based on a given prefix.

  Inputs:
    prefix: The prefix used for the MCP server.
    tools: A list of tools within the MCP server.
  Output:
    A list of strings where the prefix has been joined to each tool with an underscore.
  */
  mcpToolList = prefix: (tools: (map (tool: "${prefix}_${tool}") tools));

  # --- Plan Agent ---

  permissions.plan = buildAccessList "deny" (
    mcpToolList
    "serena"
    [
      "delete_*"
      "insert_*"
      "replace_*"
    ]
  );

  plan = {
    mode = "primary";
    tools = {
      write = {
        "*" = false;
        ".opencode/plans" = true;
      };
      edit = {
        "*" = false;
        ".opencode/plans" = true;
      };
    };

    permission = permissions.plan;
    prompt = builtins.readFile ./plan.md;
  };

  # --- Build Agent ---

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

  # --- Debug Agent ---

  debugBashAllow = buildAccessList "allow" [
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
  ];

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
      bash =
        {
          "*" = "ask";
        }
        // debugBashAllow;
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
in {
  programs.opencode = {
    settings = {
      agent = {
        plan = plan;
        build = build;
        debug = debug;
      };
    };
  };
}
