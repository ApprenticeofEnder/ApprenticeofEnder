{
  imports = [ ../../modules/shared/nix ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  home.shellAliases = {
    docker = "podman";
    pathlist = "printenv PATH | tr ':' '\n'";
  };
}
