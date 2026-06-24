{pkgs, ...}: {
  home.packages = with pkgs; [
    godot # game engine
  ];
}
