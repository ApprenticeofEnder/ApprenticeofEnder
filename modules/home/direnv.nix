{
  pkgs,
  pkgs-stable,
  ...
}: {
  # https://nixos.asia/en/direnv
  programs.direnv = {
    package = pkgs.direnv;
    enable = true;
    silent = true;
    nix-direnv = {
      enable = true;
    };
    mise = {
      enable = true;
      package = pkgs-stable.mise;
    };
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    config.global = {
      # Make direnv messages less verbose
      hide_env_diff = true;
    };
  };
}
