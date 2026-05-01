{pkgs, ...}: let
  corePlugin = name: settings: {
    enable = true;
    name = name;
    settings = settings;
  };
  communityPlugin = pkg: importSettings: {
    enable = true;
    pkg = pkg;
    settings =
      if importSettings
      then import "./plugin-configs/${pkg}.nix"
      else null;
  };
in {
  programs.obsidian = {
    defaultSettings = {
      communityPlugins = with pkgs.obsidianPlugins; [
        # TODO: Figure out how these actually get rendered, if at all
        (communityPlugin better-word-count false)
        (communityPlugin buttons false)
        (communityPlugin calendar false)
        (communityPlugin callout-manager false)
        (communityPlugin cmdr false)
        (communityPlugin colored-tags-wrangler false)
        # {
        #   enable = true;
        #   pkg = pkgs.obsidianPlugins."colored-tags-wrangler";
        #   settings =
        #     builtins.fromJSON
        #     (
        #       builtins.readFile
        #       ./plugin-configs/colored-tag-wrangler.json
        #     );
        # }
        (communityPlugin darlal-switcher-plus false)
        (communityPlugin dataview false)
        (communityPlugin excalibrain false)
        (communityPlugin modalforms false)
        (communityPlugin multi-column-markdown false)
        (communityPlugin obsidian-advanced-uri false)
        (communityPlugin obsidian-auto-link-title false)
        (communityPlugin obsidian-excalidraw-plugin false)
        # (communityPlugin obsidian-graph-presets false)
        (communityPlugin obsidian-icon-folder false)
        (communityPlugin obsidian-kanban false)
        (communityPlugin obsidian-style-settings false)
        (communityPlugin obsidian-tomorrows-daily-note false)
        (communityPlugin obsidian42-brat false)
        (communityPlugin periodic-notes false)
        (communityPlugin podnotes false)
        (communityPlugin quickadd false)
        (communityPlugin table-editor-obsidian false)
        (communityPlugin tag-wrangler false)
        (communityPlugin templater-obsidian false)
        (communityPlugin todoist-sync-plugin false)
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
