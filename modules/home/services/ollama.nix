{
  pkgs-unstable,
  lib,
  ...
}: let
  hostname =
    if builtins.pathExists /etc/hostname
    then builtins.readFile /etc/hostname
    else "";
  ollamaHostname = "ender-hornet";
  isOllamaHost = hostname == ollamaHostname;
  ollama = "${pkgs-unstable.ollama}/bin/ollama";

  # Models to pull on activation
  # Add or remove models as needed
  models = [
    "cogito:3b"
    "deepseek-coder:1.3b"
    "qwen2.5-coder:3b"
    "deepcoder:1.5b"
  ];

  modelListBash = lib.concatStringsSep " " models;
in {
  services.ollama = {
    enable = isOllamaHost;
    package = pkgs-unstable.ollama;
    port = 11434; # default
    host = "0.0.0.0"; # default
    # acceleration = "rocm";
    acceleration = "cuda"; # nvidia
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "32000";
    };
  };

  programs.opencode.settings.provider =
    if isOllamaHost
    then {
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
    }
    else {};

  # Pull models on home-manager activation
  # Note: Requires ollama service to be running, so this may need
  # to be run manually after initial activation
  home.activation.pullOllamaModels = lib.mkIf (isOllamaHost && models != []) (
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
