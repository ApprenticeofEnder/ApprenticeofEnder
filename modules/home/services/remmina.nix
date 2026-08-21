{pkgs, ...}:
with pkgs; {
  services.remmina.enable = stdenv.hostPlatform.isLinux;
}
