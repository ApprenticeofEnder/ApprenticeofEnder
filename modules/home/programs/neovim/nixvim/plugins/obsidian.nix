{...}: {
  plugins.obsidian = {
    enable = true;
    settings = {
      # keep-sorted start block=yes
      completion = {
        min_chars = 2;
        blink = true;
      };
      legacy_commands = false;
      new_notes_location = "notes_subdir";
      notes_subdir = "Notes";
      ui.enable = false;
      workspaces = [
        # TODO: Start leveraging multiple vaults
        # - Work
        # - Homelab
        # - RPG
        # - Personal
        # - Gaming
        {
          name = "Hub";
          path = "~/Obsidian/Hub";
        }
      ];
      # keep-sorted end
    };
  };
}
