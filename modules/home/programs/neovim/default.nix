{pkgs, ...}: {
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PUPPETEER_EXECUTABLE_PATH = "${pkgs.google-chrome}/bin/google-chrome-stable";
  };
  home.packages = with pkgs; [
    dotnet-sdk_10
    google-chrome
  ];
  programs.nixvim = {
    enable = true;
    nixpkgs.config.allowUnfree = true;
    imports = [./nixvim-config.nix];
  };
}
