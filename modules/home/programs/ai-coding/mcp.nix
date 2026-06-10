{
  lib,
  pkgs,
  config,
  ...
}: {
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

  # TODO: Create scripts for spooling up MCP servers in the current dir

  home.packages = with pkgs; [
    (writeShellScriptBin "docker-mcp" ''
      #!/usr/bin/env bash
      set -euo pipefail

      SERVER_NAME="$1"
      SERVER_IMAGE="$2"

      docker run --rm --interactive --name "$SERVER_NAME" "$SERVER_IMAGE"
    '')
  ];

  home = {
    activation.serena = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${lib.getExe config.programs.uv.package} tool install -p ${pkgs.python313}/bin/python3.13 serena-agent
    '';
  };

  programs.mcp = {
    enable = true;
    servers = {
      hashicorp-terraform = {
        # disabled = true;
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
        # disabled = true;
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
        command = "serena";
        args = [
          "start-mcp-server"
          "--context"
          "claude-code"
          "--project-from-cwd"
        ];
        type = "stdio";
      };
    };
  };
}
