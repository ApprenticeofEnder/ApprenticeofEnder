{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      abcde
    ];
  };
}
