{...}: {
  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
    hosts = {
      "github.com" = {
        git_protocol = "ssh";
        user = "ApprenticeofEnder";
      };
    };
    settings = {
      git_protocol = "https";
      prompt = "enabled";

      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };
}
