{...}: {
  plugins.obsidian = {
    enable = true;
    settings = {
      completion = {
        min_chars = 2;
        blink = true;
      };
      notes_subdir = "Notes";
      new_notes_location = "notes_subdir";
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
    };
  };
}
