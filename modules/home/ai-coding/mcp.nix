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

      DISCRIMINATOR=$(${lib.getExe pkgs.openssl} rand -hex 8)

      docker run --rm --interactive --name "$SERVER_NAME-$DISCRIMINATOR" "$SERVER_IMAGE"
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
        command = "docker-mcp";
        args = [
          "terraform-mcp"
          "hashicorp/terraform-mcp-server:latest"
        ];
        type = "stdio";
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
