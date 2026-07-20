{...}: let
  mkDatabase = {
    Name,
    Username,
    Password,
    Hostname ? "127.0.0.1",
    Port ? "5432",
    Provider ? "postgres",
    DBName,
    URLParams ? "",
    Commands ? [],
  }: let
    URL = "${Provider}://${Username}:${Password}@${Hostname}:${Port}/${DBName}?${URLParams}";
  in {
    inherit Name Username Password Hostname Port DBName URLParams Commands URL Provider;
  };
in {
  programs.lazysql = {
    enable = true;
    settings = {
      application = {
        DefaultPageSize = 300;
        DisableSidebar = false;
        SidebarOverlay = false;
      };

      database = [
        (
          mkDatabase {
            Name = "MTGTrader (DEV)";
            Username = "mtgtrader";
            Password = "mtgtrader";
            DBName = "mtg_trader_dev";
            URLParams = "sslmode=disable";
          }
        )
      ];
    };
  };
}
