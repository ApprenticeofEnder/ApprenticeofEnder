{lib, ...}: {
  plugins.obsidian = {
    enable = true;
    lazyLoad = {
      settings = {
        lazy = true;
        enabled = lib.nixvim.mkRaw ''
          function()
            return not vim.g.vscode
          end
        '';
      };
    };
    settings = {
      # keep-sorted start block=yes
      completion = {
        min_chars = 2;
        # blink = true;
      };
      legacy_commands = false;
      new_notes_location = "notes_subdir";
      notes_subdir = "Notes";
      ui.enable = false;
      workspaces = [
        # TODO: Start leveraging multiple vaults
        # - Homelab
        # - RPG
        # - Personal
        # - Gaming
        {
          name = "Hub";
          path = "~/Obsidian/Hub";
        }
        {
          name = "Work";
          path = "~/Obsidian/Work";
        }
      ];
      # keep-sorted end
    };
  };
}
