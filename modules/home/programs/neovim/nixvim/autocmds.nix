{
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
      callback = {
        __raw = ''
          function()
            vim.lsp.buf.format {
              async = false,
            }
          end
        '';
      };
    }
    {
      pattern = "terraform";
      desc = "Terraform Comments";
      event = [
        "FileType"
      ];
      callback = {
        __raw = ''
          function()
            vim.bo.commentstring = "# %s"
          end
        '';
      };
    }
    {
      pattern = ["*"];
      desc = "Autoformat using Conform";
      event = [
        "BufWritePre"
      ];
      callback = {
        __raw = ''
          function(args)
            require("conform").format { bufnr = args.buf }
          end
        '';
      };
    }
    {
      pattern = ["*"];
      desc = "Treesitter Spool Up";
      event = [
        "FileType"
      ];
      callback = {
        __raw = ''
          function(args)
            pcall(vim.treesitter.start)
          end
        '';
      };
    }
  ];
  autoGroup = [
  ];
}
