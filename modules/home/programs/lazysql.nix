{
  programs.lazysql = {
    enable = true;
    settings = {
      application = {
        DefaultPageSize = 300;
        DisableSidebar = false;
        SidebarOverlay = false;
      };

      database = [
        {
          Name = "MTGTrader (DEV)";
          URL = "postgresql://mtgtrader:mtgtrader@127.0.0.1:5432/mtg_trader_dev?sslmode=disable";
          Provider = "postgres";
          Username = "";
          Password = "";
          Hostname = "";
          Port = "";
          DBName = "mtg_trader_dev";
          URLParams = "";
          Commands = [ ];
        }
      ];
    };
  };
}
