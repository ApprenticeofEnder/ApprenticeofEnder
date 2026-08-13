{...}: let
  matches = [
    {
      trigger = ":date";
      replace = "{{currentdate}}";
    }
  ];
  global_vars = [
    {
      name = "currentdate";
      type = "date";
      params = {format = "%Y-%m-%d";};
    }
  ];
in {
  services.espanso = {
    enable = true;
    matches = {
      base = {
        inherit matches;
      };
      global_vars = {
        inherit global_vars;
      };
    };
  };
}
