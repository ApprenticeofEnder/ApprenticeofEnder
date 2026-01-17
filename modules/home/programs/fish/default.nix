{
  pkgs,
  lib,
  ...
}:
lib.mkMerge [
  (lib.mkIf pkgs.stdenv.isDarwin {
    programs.fish = {
      shellInit = ''
        set LIBRARY_PATH ${pkgs.libiconv}/lib
        fish_add_path "/opt/homebrew/bin/"
      '';
    };
  })
  {
    programs.fish = {
      enable = true;
      shellAliases = {
        mkdir = "mkdir -p";
      };
      functions = {
        bind_bang = ''
          switch (commandline -t)[-1]
              case "!"
                  commandline -t -- $history[1]
                  commandline -f repaint
              case "*"
                  commandline -i !
          end
        '';

        bind_dollar = ''
          switch (commandline -t)[-1]
              case "!"
                  commandline -f backward-delete-char history-token-search-backward
              case "*"
                  commandline -i '$'
          end
        '';

        fish_user_key_bindings = ''
          bind ! bind_bang
          bind '$' bind_dollar
        '';
      };
      binds = {
        "!" = "bind_bang";
        "$" = "bind_dollar";
      };
      shellInit = ''
        fish_add_path ~/.local/bin
        fish_add_path ~/.nix-profile/bin
        source "$HOME/.config/op/plugins-nix.sh"
      '';
    };
  }
]
