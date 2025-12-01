{
  # config,
  ...
}:
{
  services.cachix-agent = {
    enable = false;
    verbose = true;
    name = "ender"; # TODO: Investigate how this actually works

    # host = null;
    # credentialsFile = "${config.xdg.configHome}/cachix-agent.token"; # default
  };
}
