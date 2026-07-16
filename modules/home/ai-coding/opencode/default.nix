{
  lib,
  pkgs,
  config,
  ...
}: let
  ai_coding_lib = import ../lib {inherit lib;};
  inherit (ai_coding_lib) mkOpencodePermissionList;
  inherit (ai_coding_lib) sensitive_files;
  inherit (ai_coding_lib) lockfiles;
  inherit (ai_coding_lib) global_bash;
  inherit (ai_coding_lib) serena_tools;
  inherit (ai_coding_lib) mcpToolSet;
  inherit (ai_coding_lib) mcpToolList;

  context = import ../lib/context.nix {inherit lib pkgs;};

  read_perms = mkOpencodePermissionList {
    deny = sensitive_files.opencode;
    allow = [
      "*"
      "*.env.example"
    ];
  };

  edit_perms = mkOpencodePermissionList {
    deny = sensitive_files.opencode ++ lockfiles.opencode;
    ask = ["*"];
  };

  bash_perms = mkOpencodePermissionList {
    deny = global_bash.deny;
    ask = global_bash.ask;
    allow = global_bash.allow;
  };

  provider_env = lib.mergeAttrsList [
    {
      OPENROUTER_API_KEY = "op://Private/OpenRouter API Key - 1Password/credential";
    }
    (lib.optionalAttrs (pkgs.stdenv.isDarwin) {
      AWS_BEARER_TOKEN_BEDROCK = "op://Work/Amazon Bedrock API Key/credential";
    })
  ];

  # TODO: Research opencode models on openrouter
  # - Cohere North series
  # - Kimi series
  # - GLM series
  # - NVIDIA Nemotron
  # - Qwen 3.7
  # - Minimax
  # - OpenRouter Owl Alpha
  # - StepFun?
  # - Laguna
  # - DeepSeek
  # - Xiaomi MiMo

  providers = lib.mergeAttrsList [
    {
      openrouter = {
        npm = "@ai-sdk/openai-compatible";
        options = {
          baseURL = "https://openrouter.ai/api/v1";
          apiKey = "{env:OPENROUTER_API_KEY}";
        };
      };
    }
  ];

  env_tpl = with builtins;
    concatStringsSep "\n" (
      attrValues (
        mapAttrs (var_name: secret_ref: "${var_name}=${secret_ref}")
        provider_env
      )
    );

  env_tpl_name = "opencode/.env.tpl";

  mcp_tools = {
    serena = mcpToolSet {
      name = "serena";
      tools = {
        basic = serena_tools.basic;
        edit = serena_tools.edit;
      };
      agent = "opencode";
    };
  };
in {
  xdg.configFile = {
    ${env_tpl_name} = {
      text = env_tpl;
    };
  };

  home.shellAliases = {
    opencode = ''export $(op inject -i ${config.xdg.configHome}/${env_tpl_name}) && ${lib.getExe pkgs.opencode}'';
  };

  programs.opencode = {
    enable = true;
    # enableMcpIntegration = true;

    tui = {
      theme = "nord";
      diff_style = "stacked";
    };

    skills = ../skills;

    context = context;

    settings = {
      autoshare = false;
      autoupdate = false;

      provider = providers;

      mcp = {
        hashicorp-terraform = {
          command = [
            "docker"
            "run"
            "--rm"
            "--interactive"
            "--name"
            "terraform-mcp"
            "hashicorp/terraform-mcp-server:latest"
          ];
          type = "local";
        };
        serena = {
          command = [
            "serena"
            "start-mcp-server"
            "--context"
            "claude-code"
            "--project-from-cwd"
          ];
          type = "local";
        };
      };

      # TODO: Make these deny by default
      permission =
        {
          read = read_perms;
          edit = edit_perms;
          bash = bash_perms;
          webfetch = "allow";
          websearch = "ask";
          grep = read_perms;
          glob = read_perms;

          skill = mkOpencodePermissionList {
            allow = ["caveman"];
          };
        }
        // (
          mkOpencodePermissionList {
            allow = mcp_tools.serena.basic;
            ask = mcpToolList.opencode {
              name = "serena";
              tools = ["*"];
            };
          }
        );
    };
  };
}
