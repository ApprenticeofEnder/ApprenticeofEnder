{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      abcde
    ];

    shellAliases = {
      cdrip = "abcde -o flac -B";
    };
  };
}
