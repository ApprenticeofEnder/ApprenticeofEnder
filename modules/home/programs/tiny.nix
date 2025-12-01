{ config
, pkgs
, ...
}:
let
  profile = {
    realname = config.me.fullname;
    nicks = [ config.me.username ];
  };
in
{
  programs.tiny = {
    enable = pkgs.stdenv.isLinux;
    settings = {
      servers = [
        {
          tls = true;
          port = 6697;
          addr = "irc.libera.chat";
          realname = profile.realname;
          nicks = profile.nicks;
          join = [ "#libera" ];
        }
        {
          tls = true;
          port = 6697;
          addr = "irc.oftc.net";
          realname = profile.realname;
          nicks = profile.nicks;
          join = [
            "#oftc"
            "#moocows"
          ];
        }
      ];
      defaults = {
        nicks = profile.nicks;
        realname = profile.realname;
        join = [ ];
        tls = true;
      };
    };
  };
}
