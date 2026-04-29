{lib, ...}: let
  interpolateTermcode = termcode: ''" .. ${termcode} .. "'';
  # cmd = interpolateTermcode "cmd";
  # enter = interpolateTermcode "enter";
  esc = interpolateTermcode "esc";

  mkMacro = register: sequence:
    lib.nixvim.mkRaw ''
      vim.fn.setreg("${register}", "${sequence}")
    '';

  consolidateMacros = macros:
    lib.concatStringsSep "\n" (
      map (macro: macro.__raw) macros
    );

  macros = [
    (mkMacro "h" "iHello, world!${esc}o:D${esc}:w")
  ];
in {
  extraConfigLuaPost = ''
    local esc = vim.api.nvim_replace_termcodes("<ESC>", true, true, true)
    local cmd = vim.api.nvim_replace_termcodes("<cmd>", true, true, true)
    local enter = vim.api.nvim_replace_termcodes("<CR>", true, true, true)
    pcall(
      require "experimental"
    )
    ${consolidateMacros macros}
  '';
}
