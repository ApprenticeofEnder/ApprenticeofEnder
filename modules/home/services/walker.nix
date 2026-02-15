{pkgs, ...}: {
  home.packages = with pkgs; [
    elephant
  ];
  services.walker = {
    enable = pkgs.stdenv.isLinux;
  };
}
