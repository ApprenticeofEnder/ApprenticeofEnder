{...}: {
  imports = [
    ./completions.nix
    ./shell-init.nix
  ];
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
  };
}
