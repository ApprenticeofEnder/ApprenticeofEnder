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

  # Models to pull on activation
  # Add or remove models as needed
  models = [
    "cogito:3b"
    "deepseek-coder:1.3b"
    "qwen2.5-coder:3b"
    "deepcoder:1.5b"
  ];
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

  # Pull models on home-manager activation
  # Note: Requires ollama service to be running, so this may need
  # to be run manually after initial activation
  home.activation.pullOllamaModels = lib.mkIf (isOllamaHost && models != []) (
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      if command -v ${pkgs-unstable.ollama}/bin/ollama &> /dev/null; then
        for model in ${lib.concatStringsSep " " models}; do
          echo "Pulling $model..."
          ${pkgs-unstable.ollama}/bin/ollama pull "$model" || echo "Warning: Failed to pull $model (service may not be running)"
        done
      fi
    ''
  );
}
