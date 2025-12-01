{ pkgs, ... }: with pkgs; { services.remmina.enable = stdenv.isLinux; }
