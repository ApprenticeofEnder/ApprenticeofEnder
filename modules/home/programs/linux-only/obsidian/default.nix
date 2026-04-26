{pkgs, ...}: let
  obsidianRoot = "Obsidian";
  systemFolder = name: "_system/${name}";
  cssSnippet = name: "./snippets/${name}.css";
  enabledCssSnippets = [
    # keep-sorted start
    "MCL Gallery Cards"
    "MCL Multi Column"
    "MCL Wide Views"
    "callouts"
    "graph"
    # keep-sorted end
  ];
  plugin = name: settings: {
    enable = true;
    name = name;
    settings = settings;
  };
in {
  home.packages = with pkgs; [
    obsidian
  ];
  programs.obsidian = {
    enable = false;
    defaultSettings = {
      # keep-sorted start block=yes

      # [
      # keep-sorted start
      #   "templater-obsidian",
      #   "obsidian-tomorrows-daily-note",
      #   "todoist-sync-plugin",
      #   "tag-wrangler",
      #   "obsidian-style-settings",
      #   "obsidian-reading-time",
      #   "quickadd",
      #   "darlal-switcher-plus",
      #   "periodic-notes",
      #   "multi-column-markdown",
      #   "obsidian-kanban",
      #   "obsidian-icon-folder",
      #   "obsidian-graph-presets",
      #   "obsidian-excalidraw-plugin",
      #   "dataview",
      #   "excalibrain",
      #   "cmdr",
      #   "colored-tags-wrangler",
      #   "callout-manager",
      #   "calendar",
      #   "buttons",
      #   "obsidian42-brat",
      #   "obsidian-book-search-plugin",
      #   "better-word-count",
      #   "obsidian-auto-link-title",
      #   "obsidian-advanced-uri",
      #   "table-editor-obsidian",
      #   "modalforms"
      # keep-sorted end
      app = {
        # keep-sorted start block=yes
        alwaysUpdateLinks = true;
        attachmentFolderPath = systemFolder "Attachments";
        newFileFolderPath = "Notes";
        newFileLocation = "folder";
        newLinkFormat = "shortest";
        pdfExportSettings = {
          includeName = true;
          pageSize = "Letter";
          landscape = false;
          margin = "0";
          downscalePercent = 100;
        };
        promptDelete = false;
        readableLineLength = false;
        showInlineTitle = true;
        vimMode = true;
        # keep-sorted end
      };
      appearance = {
        # keep-sorted start block=yes
        accentColor = "#00ff33";
        baseFontSizeAction = false;
        cssTheme = "Encore";
        enabledCssSnippets = enabledCssSnippets;
        interfaceFontFamily = "Inter";
        monospaceFontFamily = "Ubuntu Mono";
        textFontFamily = "Inter";
        theme = "obsidian";
        # keep-sorted end
      };
      # ]
      communityPlugins = [
      ];
      corePlugins =
        # Plugins without config
        map (name: plugin name null) [
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
          (plugin "backlink" {
            backlinkInDocument = true;
          })
          (plugin "canvas" {
            snapToObjects = true;
            snapToGrid = true;
            newFileLocation = "folder";
            newFileFolderPath = "Canvases";
          })
          (plugin "command-palette" null)
          (plugin "file-recovery" null)
          (plugin "footnotes" null)
          (plugin "graph" null)
          (plugin "note-composer" null)
          (plugin "page-preview" null)
          (plugin "sync" null)
          (plugin "workspaces" null)
        ];
      cssSnippets =
        map (name: {
          source = cssSnippet name;
          enable = true;
        })
        enabledCssSnippets;
      extraFiles = {
      };
      hotkeys = {
      };
      themes = [
      ];
      # keep-sorted end
    };
    vaults = {
      hub = {
        enable = false;
        target = "${obsidianRoot}/Hub";
        # settings = {};
      };
      # TODO: Add work, RPG, gaming, homelab, personal
    };
  };
}
