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

  mkOpenrouterProvider = models: {
    npm = "@ai-sdk/openai-compatible";
    options = {
      baseURL = "https://openrouter.ai/api/v1";
      apiKey = "{env:OPENROUTER_API_KEY}";
    };
    models =
      builtins.mapAttrs (
        # deadnix: skip
        model: metadata:
          metadata
          // {
            name = "${metadata.name} - OpenRouter";
          }
      )
      models;
  };

  providers = lib.mergeAttrsList [
    {
      # keep-sorted start block=yes
      cohere = mkOpenrouterProvider {
        "cohere/north-mini-code:free" = {
          name = "Cohere North Mini (Free)";
        };
      };
      deepseek = mkOpenrouterProvider {
        "deepseek/deepseek-v4-flash" = {
          name = "DeepSeek V4 Flash";
        };
      };
      minimax = mkOpenrouterProvider {
        "minimax/minimax-m3" = {
          name = "MiniMax M3";
        };
      };
      moonshot = mkOpenrouterProvider {
        "moonshotai/kimi-k2.7-code" = {
          name = "Kimi K2.7 Code";
        };
      };
      nvidia = mkOpenrouterProvider {
        "nvidia/nemotron-3-ultra-550b-a55b" = {
          name = "Nvidia Nemotron 3 Ultra";
        };
      };
      openrouter = mkOpenrouterProvider {
        "openrouter/owl-alpha" = {
          name = "OpenRouter Owl Alpha";
        };
      };
      z-ai = mkOpenrouterProvider {
        "z-ai/glm-5.2" = {
          name = "Z.ai GLM 5.2";
        };
      };
      # keep-sorted end
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
