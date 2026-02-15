{...}: {
  imports = [../../modules/shared/nix];

  home = {
    shellAliases = {
      # docker = "podman";
      pathlist = ''printenv PATH | tr ":" "\n"'';
      yay = ''PATH="/usr/bin:$PATH" yay'';
    };
  };
}
