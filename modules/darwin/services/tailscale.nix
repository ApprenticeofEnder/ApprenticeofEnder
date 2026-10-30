{...}: {
  services.tailscale.enable = true;

  # Resolves a conflict between tailscale 1.104 using os.Root
  # and nix-darwin trying to link /etc/resolver/ts.net into /etc/static
  # NOTE: tailscaled writes this file itself
  environment.etc."resolver/ts.net".enable = false;
}
