{lib}: rec {
  interpolate = termcode: ''" .. ${termcode} .. "'';
  defineTermcode = name: termcode: ''
    local ${name} = vim.api.nvim_replace_termcodes("${termcode}", true, true, true)
  '';
  termcodeDefs = {
    # keep-sorted start
    cmd = defineTermcode "cmd" "<cmd>";
    enter = defineTermcode "enter" "<CR>";
    esc = defineTermcode "esc" "<ESC>";
    # keep-sorted end
  };

  # cmd = interpolate "cmd";
  enter = interpolate "enter";
  esc = interpolate "esc";

  mkMacro = register: sequence:
    lib.nixvim.mkRaw ''
      vim.fn.setreg("${register}", "${sequence}")
    '';

  consolidateMacros = macros:
    lib.concatStringsSep "\n" (
      map (macro: macro.__raw) macros
    );
}
