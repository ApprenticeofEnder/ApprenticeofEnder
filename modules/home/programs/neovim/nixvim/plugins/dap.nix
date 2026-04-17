let
  lazyLoad = {
    settings.cmd = ["DapContinue" "DapToggleBreakpoint"];
  };
in {
  plugins = {
    dap =
      lazyLoad
      // {
        enable = true;
      };
    dap-python =
      lazyLoad
      // {
        enable = true;
      };
  };
}
