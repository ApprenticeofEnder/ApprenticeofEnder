{lib, ...}: let
  # leader = "<leader>";
  # cmd = "<cmd>";
  # enter = "<CR>";
  esc = "<ESC>";
  mkMacro = register: sequence:
    lib.nixvim.mkRaw ''
      vim.fn.setreg("${register}", "${sequence}")
    '';

  consolidateMacros = macros:
    lib.concatStringsSep "\n" (
      map (macro: macro.__raw) macros
    );

  macros = [
    (mkMacro "h" "iHello, world!${esc}o:D${esc}")
  ];
in {
  extraLuaConfigPost = ''
    pcall(
      require "experimental"
    )
    ${consolidateMacros macros}
  '';
}
