{pkgs, ...}: let
  corePlugin = name: settings: {
    enable = true;
    name = name;
    settings = settings;
  };
  communityPlugin = pkgName: settings: {
    enable = true;
    pkg = pkgs.obsidianPlugins.${pkgName};
    settings = settings;
  };
in {
  programs.obsidian = {
    defaultSettings = {
      communityPlugins = [
        (communityPlugin "better-word-count" null)
        (communityPlugin "buttons" null)
        (communityPlugin "calendar" null)
        (communityPlugin "callout-manager" {
          callouts = {
            custom = [];
            settings = {};
          };
          calloutDetection = {
            obsidian = true;
            theme = true;
            snippet = true;
          };
        })
      ];
      corePlugins =
        # Plugins without config
        map (name: corePlugin name null) [
          "bases"
          "bookmarks"
          "editor-status"
          "file-explorer"
          "global-search"
          "markdown-importer"
          "outgoing-link"
          "outline"
          "tag-pane"
        ]
        ++ [
          (corePlugin "backlink" {
            backlinkInDocument = true;
          })
          (corePlugin "canvas" {
            snapToObjects = true;
            snapToGrid = true;
            newFileLocation = "folder";
            newFileFolderPath = "Canvases";
          })
          (corePlugin "command-palette" null)
          (corePlugin "file-recovery" null)
          (corePlugin "footnotes" null)
          (corePlugin "graph" null)
          (corePlugin "note-composer" null)
          (corePlugin "page-preview" null)
          (corePlugin "sync" null)
          (corePlugin "workspaces" null)
        ];
    };
  };
}
