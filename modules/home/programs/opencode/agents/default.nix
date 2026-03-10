# TODO: Create other agents based on needs
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

  permissions = {};
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
  /*
  Agents:
  - Diagnostic/Debug
  - Code Reviewer
  - Terraform/IaC
  - Security Analyst
  - Docs
  - Testing
  */
in {
  programs.opencode = {
    settings = {
      agent = {
        plan = plan;
      };
    };
  };
}
