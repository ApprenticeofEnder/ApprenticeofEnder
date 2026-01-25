{pkgs-unstable, ...}: let
  hostname = builtins.pathExists /etc/hostname && builtins.readFile /etc/hostname;
  ollamaHostname = "ender-hornet";
in {
  services.ollama = {
    enable = hostname == ollamaHostname;
    package = pkgs-unstable.ollama;
    port = 11434; # default
    host = "0.0.0.0"; # default
    # acceleration = "rocm";
    acceleration = "cuda"; # nvidia
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "32000";
    };
  };
}
