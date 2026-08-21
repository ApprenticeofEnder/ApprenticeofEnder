{
  pkgs,
  lib,
  ...
}: let
  workingDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "home"
    else "inherit";

  keysLua = lib.generators.mkLuaInline ''
    {
      -- Split
      { key = "d", mods = "SUPER",           action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
      { key = "d", mods = "SUPER|SHIFT",     action = wezterm.action.SplitVertical({   domain = "CurrentPaneDomain" }) },
      -- Across
      { key = "t", mods = "SUPER",        action = wezterm.action.SpawnTab("CurrentPaneDomain") },
      { key = "[", mods = "SUPER|SHIFT",  action = wezterm.action.ActivateTabRelative(-1) },
      { key = "]", mods = "SUPER|SHIFT",  action = wezterm.action.ActivateTabRelative(1) },
      -- Navigate
      { key = "h", mods = "SUPER|ALT",  action = wezterm.action.ActivatePaneDirection("Left") },
      { key = "l", mods = "SUPER|ALT",  action = wezterm.action.ActivatePaneDirection("Right") },
      { key = "k", mods = "SUPER|ALT",  action = wezterm.action.ActivatePaneDirection("Up") },
      { key = "j", mods = "SUPER|ALT",  action = wezterm.action.ActivatePaneDirection("Down") },
      -- Zoom
      { key = "f", mods = "SUPER|SHIFT",  action = wezterm.action.TogglePaneZoomState },
      -- Destroy
      { key = "w", mods = "SUPER",  action = wezterm.action.CloseCurrentPane({ confirm = true }) },
      -- Clipboard
      { key = "v", mods = "CTRL|SHIFT",  action = wezterm.action.PasteFrom("PrimarySelection") },
      { key = "v", mods = "CTRL",        action = wezterm.action.PasteFrom("Clipboard") },
      -- Font Size
      { key = "=", mods = "SUPER",  action = wezterm.action.IncreaseFontSize },
      { key = "-", mods = "SUPER",  action = wezterm.action.DecreaseFontSize },
      { key = "0", mods = "SUPER",  action = wezterm.action.ResetFontSize },
    }
  '';
in
  lib.mkMerge [
    {
      programs.wezterm = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        settings = {
          default_prog = ["${pkgs.fish}/bin/fish"];
          scrollback_lines = 30000000;
          color_scheme = "Nord (Gogh)";
          font = lib.generators.mkLuaInline ''wezterm.font("Hack Nerd Font")'';
          set_environment_variables = {
            LS_COLORS = "1";
          };
          default_cwd = workingDirectory;
          keys = keysLua;
        };
        extraConfig = ''
          -- Source - https://stackoverflow.com/a/78743561
          -- Posted by lllspecter
          -- Retrieved 2026-08-18, License - CC BY-SA 4.0
          local mux = wezterm.mux
          wezterm.on("gui-startup", function(cmd)
              local tab, pane, window = mux.spawn_window(cmd or {})
              window:gui_window():maximize()
          end)
        '';
      };
    }
    (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      programs.wezterm.settings.send_composed_key_when_left_alt_is_pressed = false;
    })
  ]
