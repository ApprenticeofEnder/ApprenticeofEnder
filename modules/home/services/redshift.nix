{...}: {
  services.redshift = {
    enable = true;
    tray = true;
    dawnTime = "7:00-9:00";
    duskTime = "19:30-21:00";
    temperature = {
      day = 5700;
      night = 1200;
    };
    settings = {
      redshift = {
        fade = 1;
        gamma = 1;
        adjustment-method = "randr";
      };

      randr = {
        screen = 0;
      };
    };
  };
}
