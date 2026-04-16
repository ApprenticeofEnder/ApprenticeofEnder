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
    autoclose.enable = true;
    neoscroll.enable = true;
    precognition.enable = true;
    snacks.enable = true;
    snacks.settings = {
      input.enable = true;
    };
    todo-comments.enable = true;
    ts-autotag.enable = true;
    ts-context-commentstring.enable = true;
    which-key.enable = true;
    which-key.settings = {
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
    # keep-sorted end
  };

  extraPlugins = with pkgs.vimPlugins; [
    plenary-nvim
    vscode-nvim
  ];
}
