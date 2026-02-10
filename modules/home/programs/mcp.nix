{...}: {
  # TODO: Investigate these MCP servers:
  # https://github.com/augmnt/augments-mcp-server
  # https://github.com/securityfortech/secops-mcp
  # https://github.com/exoticknight/mcp-file-merger
  # https://github.com/8b-is/smart-tree
  # https://github.com/CodeGraphContext/CodeGraphContext
  # https://github.com/trilogy-group/aws-pricing-mcp
  # https://github.com/Flux159/mcp-server-kubernetes
  # https://github.com/oraios/serena

  # Need this for uvx
  programs.uv.enable = true;
  programs.mcp = {
    enable = true;
    servers = {
      hashicorp-terraform = {
        disabled = true;
        command = "docker";
        args = [
          "run"
          "--rm"
          "--interactive"
          "--name"
          "terraform-mcp"
          "hashicorp/terraform-mcp-server:latest"
        ];
        type = "stdio";
      };
      aws-terraform = {
        disabled = true;
        command = "docker";
        args = [
          "run"
          "--rm"
          "--interactive"
          "--name"
          "aws-terraform-mcp"
          "mcp/aws-terraform:latest"
        ];
        type = "stdio";
        env = {
          FASTMCP_LOG_LEVEL = "ERROR";
        };
      };
      serena = {
        command = "uvx";
        args = [
          "--from"
          "git+https://github.com/oraios/serena"
          "serena"
          "start-mcp-server"
          "--context"
          "ide"
          "--project-from-cwd"
        ];
        type = "stdio";
      };
    };
  };
}
