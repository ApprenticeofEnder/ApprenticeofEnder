{
  # config,
  ...
}: {
  programs.git = {
    enable = true;
    lfs.enable = false;
    maintenance.enable = false;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = false;

      user = {
        name = "Robert Babaev";
        email = "github@robertbabaev.tech";
      };
      alias = {
        ga = "git add .";
        gama = "";
      };
    };

    # signing = {
    #   # format = "ssh";
    #   signByDefault = true;
    # };

    ignores = [
      "*~"
      "*.swp"
    ];
  };
}
