{lib, ...}: let
  helpers = import ./helpers.nix {
    inherit lib;
  };
  terraform = [
    {
      pattern = [
        "*.tf"
        "*.tfvars"
      ];
      desc = "Autoformat for Terraform";
      event = [
        "BufWritePre"
      ];
      callback = lib.nixvim.mkRaw ''
        function()
          vim.lsp.buf.format {
            async = false,
          }
        end
      '';
    }
    {
      pattern = "terraform";
      desc = "Terraform Comments";
      event = [
        "FileType"
      ];
      callback = lib.nixvim.mkRaw ''
        function()
          vim.bo.commentstring = "# %s"
        end
      '';
    }
  ];

  macroDefs = with helpers; {
    global = [
      (mkMacro "h" "iHello, world!${esc}o:D${esc}:w${enter}")
    ];
    nix = [
      (mkMacro "a" "i{${esc}f}a;${esc}:w${enter}F{a") # Attribute set
    ];
  };

  macroCmds = with helpers; [
    {
      pattern = "nix";
      desc = "Nix macros";
      event = [
        "FileType"
      ];
      callback = lib.nixvim.mkRaw ''
        function()
          ${consolidateMacros macroDefs.nix}
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
in
  with helpers; {
    extraConfigLuaPre =
      builtins.concatStringsSep "\n"
      (map (key: termcodeDefs."${key}") (
        builtins.attrNames termcodeDefs
      ));

    extraConfigLuaPost = ''
      pcall(require, "experimental")
      ${consolidateMacros macroDefs.global}
    '';

    autoCmd =
      terraform
      ++ macroCmds
      ++ [
        {
          pattern = ["*"];
          desc = "Autoformat using Conform";
          event = [
            "BufWritePre"
          ];
          callback = lib.nixvim.mkRaw ''
            function(args)
              require("conform").format { bufnr = args.buf }
            end
          '';
        }
        {
          pattern = "TSUpdate";
          event = [
            "User"
          ];
          callback = lib.nixvim.mkRaw ''
            function()
              require('nvim-treesitter.parsers').ghactions = {
                install_info = {
                  url = 'https://github.com/rmuir/tree-sitter-ghactions',
                  queries = 'queries',
                },
              }
            end
          '';
        }
        {
          pattern = ["*"];
          event = [
            "TermOpen"
          ];
          callback = lib.nixvim.mkRaw ''
            function()
              vim.cmd('startinsert')
            end
          '';
        }
      ];
  }
