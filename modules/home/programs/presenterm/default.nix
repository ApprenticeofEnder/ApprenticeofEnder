{pkgs, ...}: {
  home.packages = with pkgs; [
    presenterm
  ];

  xdg.configFile = {
    "presenterm/config.yaml" = {
      source = ./config.yaml;
    };
  };
}
