{...}: {
  plugins.blink-cmp = {
    enable = true;
    settings = {
      signature = {
        enabled = true;
      };
      keymap = {
        preset = "enter";
      };
      completion = {
        documentation = {
          auto_show = true;
        };
      };
    };
  };
}
