{
  config,
  lib,
  pkgs-ollama,
  ...
}:
with lib; let
  cfg = config.toolkits.ai-server;

  ollama = "${getExe config.services.ollama.package}";

  modelListBash = concatStringsSep " " cfg.models;
in {
  options.toolkits.ai-server = {
    # keep-sorted start block=yes newline_separated=yes
    acceleration = mkOption {
      type = types.nullOr (types.enum [
        false
        "rocm"
        "cuda"
        "vulkan"
      ]);
      default = "cuda";
    };

    bindHost = mkOption {
      type = types.str;
      default = "127.0.0.1";
      example = "0.0.0.0";
      description = "The host on which ollama listens.";
    };

    contextLength = mkOption {
      type = types.int;
      default = 32000;
      example = 4096;
    };

    enable = mkEnableOption "An Ollama-powered AI server.";

    environmentVariables = mkOption {
      type = with types; attrsOf str;
      default = {};
      example = {
        OLLAMA_LLM_LIBRARY = "cpu";
        HIP_VISIBLE_DEVICES = "0,1";
      };
    };

    models = mkOption {
      type = with types; listOf str;
      default = [];
      example = [
        "deepseek-coder:1.3b"
        "qwen2.5-coder:3b"
      ];
    };

    port = mkOption {
      type = types.int;
      default = 11434;
      example = 11111;
    };

    serverHost = mkOption {
      type = types.str;
      default = "localhost";
      example = "ai-server.example.com";
      description = "The hostname to reach Ollama.";
    };

    serverName = mkOption {
      type = types.str;
      default = "ollama-server";
      example = "my-awesome-ai-server";
      description = "The name to use in the OpenCode provider";
    };
    # keep-sorted end
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs-ollama.ollama;
      port = cfg.port;
      host = cfg.bindHost;
      acceleration = cfg.acceleration;
      environmentVariables =
        {
          OLLAMA_CONTEXT_LENGTH = "${builtins.toString cfg.contextLength}";
        }
        // cfg.environmentVariables;
    };

    programs.opencode.settings = {
      provider = {
        "ollama-${cfg.serverName}" = {
          npm = "@ai-sdk/openai-compatible";
          name = "ollama@${cfg.serverName}";
          options = {
            "baseURL" = "http://${cfg.serverHost}:${builtins.toString cfg.port}/v1";
          };
          models = genAttrs cfg.models (model: {
            name = model;
          });
        };
      };
    };

    home.activation.pullOllamaModels = lib.mkIf (cfg.models != []) (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        if ! command -v ${ollama} &> /dev/null; then
          echo "Ollama not available." && exit 1
        fi

        for model in ${modelListBash}; do
          echo "Pulling $model..."
          ${ollama} pull "$model" ||
            echo "Warning: Failed to pull $model (service may not be running)"
        done
      ''
    );
  };
}
