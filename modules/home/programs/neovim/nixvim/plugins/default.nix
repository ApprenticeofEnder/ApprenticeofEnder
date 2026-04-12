{...}: let
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
    todo-comments.enable = true;
    ts-autotag.enable = true;
    ts-context-commentstring.enable = true;
    which-key.enable = true;
    # keep-sorted end
  };

  # extraPlugins = with pkgs.vimPlugins; [
  #   onenord-nvim
  #   treewalker-nvim
  #   nvim-hlslens
  # ];
}
