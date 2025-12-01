{ config
, pkgs
, ...
}:
{
  # https://nixos.asia/en/direnv
  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv = {
      enable = true;
    };
    mise.enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    config.global = {
      # Make direnv messages less verbose
      hide_env_diff = true;
    };
  };
}
