{
  perSystem = {
    self',
    pkgs,
    lib,
    ...
  }: {
    # Enables 'nix run' to activate home-manager config.
    apps.default = {
      inherit (self'.packages.activate) meta;
      program = pkgs.writeShellApplication {
        name = "activate-home";
        text = ''
          set -x

          if ${lib.getExe self'.packages.activate} "$(id -un)"@"$(hostname -s)"; then
            exit 0
          else
            ${lib.getExe self'.packages.activate} "$(id -un)"@
          fi
        '';
      };
    };
  };
}
