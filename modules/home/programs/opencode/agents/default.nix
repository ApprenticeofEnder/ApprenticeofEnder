# TODO: Create other agents based on needs
{...}: let
  buildAccessList = accessValue: (
    list:
      builtins.listToAttrs (
        map
        (
          permission: {
            name = permission;
            value = accessValue;
          }
        )
        list
      )
  );

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
      write = false;
      edit = false;
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
