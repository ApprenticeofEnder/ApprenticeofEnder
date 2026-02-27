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

  serenaPlanDeny = buildAccessList "deny" (
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

    permission = serenaPlanDeny;
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
