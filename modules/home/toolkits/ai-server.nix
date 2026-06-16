{
  lib,
  pkgs,
  ...
}: let
  ollama = "${pkgs.ollama}/bin/ollama";
  models = [
    "cogito:3b"
    "deepseek-coder:1.3b"
    "qwen2.5-coder:3b"
    "deepcoder:1.5b"
    "granite4.1:3b"
  ];

  # TODO: Investigate the following models:
  # - https://ollama.com/library/gemma4
  # - https://ollama.com/library/qwen3.5
  # - https://ollama.com/library/laguna-xs.2

  modelListBash = lib.concatStringsSep " " models;
in {
  home.packages = with pkgs; [
    python313Packages.mlx-lm
  ];
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    port = 11434; # default
    host = "0.0.0.0"; # default
    # acceleration = "rocm";
    acceleration = "cuda"; # nvidia
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "32000";
    };
  };

  programs.opencode.settings = {
    # model = "ollama-ender/${builtins.elemAt models 0}";
    provider = {
      ollama-ender = {
        npm = "@ai-sdk/openai-compatible";
        name = "ollama@ender-raptor";
        options = {
          "baseURL" = "http://localhost:11434/v1";
        };
        models = lib.genAttrs models (model: {
          name = model;
        });
      };
    };
  };

  home.activation.pullOllamaModels = lib.mkIf (models != []) (
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
}
