{pkgs, ...}: let
  filterFiles = filename: (
    filename
    != "default.nix"
  );
in {
  imports = with builtins;
    map (fn: ./${fn}) (filter filterFiles (attrNames (readDir ./.)));
  plugins = {
    # keep-sorted start block=yes
    lz-n.enable = true;
    nvim-autopairs = {
      enable = true;
      lazyLoad = {
        settings.event = ["InsertEnter"];
      };
      settings = {
        check_ts = true;
        disable_filetype = [
          "TelescopePrompt"
          "vim"
        ];
      };
    };
    snacks = {
      enable = true;
      settings = {
        input.enable = true;
        picker.enable = true;
      };
    };
    ts-autotag = {
      enable = true;
      lazyLoad = {
        settings.event = ["BufRead"];
      };
    };
    ts-context-commentstring.enable = true;
    which-key = {
      enable = true;
      settings = {
        cmd = "WhichKey";
        triggers = [
          {
            __unkeyed-1 = "<leader>";
            mode = ["n" "v"];
          }

          {
            __unkeyed-1 = "<c-w>";
            mode = ["n" "v"];
          }
        ];
      };
    };
    # keep-sorted end
  };

  extraPlugins = with pkgs.vimPlugins; [
    plenary-nvim
    vscode-nvim
  ];
}
