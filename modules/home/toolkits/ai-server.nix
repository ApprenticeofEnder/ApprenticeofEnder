{
  lib,
  pkgs-unstable,
  ...
}: let
  ollama = "${pkgs-unstable.ollama}/bin/ollama";
  models = [
    "cogito:3b"
    "deepseek-coder:1.3b"
    "qwen2.5-coder:3b"
    "deepcoder:1.5b"
  ];

  modelListBash = lib.concatStringsSep " " models;
in {
  services.ollama = {
    enable = true;
    package = pkgs-unstable.ollama;
    port = 11434; # default
    host = "0.0.0.0"; # default
    # acceleration = "rocm";
    acceleration = "cuda"; # nvidia
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "32000";
    };
  };

  programs.opencode.settings.provider = {
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
