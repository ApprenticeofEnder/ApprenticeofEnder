{lib, ...}: {
  autoCmd = [
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
  ];
  autoGroup = [
  ];
}
