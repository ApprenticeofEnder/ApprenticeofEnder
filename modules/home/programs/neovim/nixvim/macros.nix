{lib, ...}: let
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
  macros = {
    global = [
      (mkMacro "h" "iHello, world!${esc}o:D${esc}:w${enter}")
    ];
    nix = [
      (mkMacro "a" "i{${esc}f}a;${esc}:w${enter}F{a") # Attribute set
    ];
  };
in {
  extraConfigLuaPre =
    builtins.concatStringsSep "\n"
    (map (key: termcodeDefs."${key}") (
      builtins.attrNames termcodeDefs
    ));

  extraConfigLuaPost = ''
    pcall(
      require "experimental"
    )
    ${consolidateMacros macros.global}
  '';

  autoCmd = [
    {
      pattern = "nix";
      desc = "Nix macros";
      event = [
        "FileType"
      ];
      callback = lib.nixvim.mkRaw ''
        function()
          ${consolidateMacros macros.nix}
        end
      '';
    }
    {
      pattern = ["*"];
      desc = "Sort keep-sorted section macro";
      event = [
        "BufEnter"
      ];
      callback = lib.nixvim.mkRaw ''
        function()
          vim.fn.setreg(
            "s",
            ":!keep-sorted ${interpolate "vim.api.nvim_buf_get_name(0)"}${enter}"
          )
        end
      '';
    }
  ];
}
