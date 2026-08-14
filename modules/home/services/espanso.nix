{...}: let
  matches = [
    {
      trigger = ":date";
      replace = "{{currentdate}}";
    }
    {
      trigger = ":datemdy";
      replace = "{{currentdate_mdy}}";
    }
    {
      trigger = ":datedmy";
      replace = "{{currentdate_dmy}}";
    }
    {
      trigger = ":ealias";
      form = ''
        [[username]]@[[domain]]
      '';
      form_fields = {
        domain = {
          default = "public.robertbabaev.tech";
        };
      };
    }
  ];
  global_vars = [
    {
      name = "currentdate";
      type = "date";
      params = {format = "%Y-%m-%d";};
    }
    {
      name = "currentdate_mdy";
      type = "date";
      params = {format = "%m/%d/%Y";};
    }
    {
      name = "currentdate_dmy";
      type = "date";
      params = {format = "%d/%m/%Y";};
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
